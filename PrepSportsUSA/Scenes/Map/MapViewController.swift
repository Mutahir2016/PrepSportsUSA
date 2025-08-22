//
//  MapViewController.swift
//  Lumen
//
//  Created by Syed Mutahir Pirzada on 13/02/2025.
//

import UIKit
import GoogleMaps
import CoreLocation
import Alamofire
import GoogleMapsUtils
import Fastis

class MapViewController: BaseViewController, CLLocationManagerDelegate, GMUClusterManagerDelegate, GMSMapViewDelegate, GMUClusterRendererDelegate {

    @IBOutlet weak var dateRangeLbl: UILabel!
    @IBOutlet weak var pMapView: GMSMapView!
    @IBOutlet weak var activityIndicator: LoadingIndicatorView!

    var clusterManager: GMUClusterManager?
    var locationManager = CLLocationManager()
    var newLocation = CLLocation()
    var bLocationReceived = false
    var pLocationString = ""
    var bIsLocEnabled: Bool = true
    var bIsAPICalled: Bool = false
    var cordinatesForNav = CLLocationCoordinate2D()
    var navView: UIView?
    var viewModel: MapViewModel!
    var selectedDateRange: FastisRange?

    override func callingInsideViewDidLoad() {
        self.title = "Locations"
        bindUI()
        viewModel.delegate = self
        viewModel.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 🚀 Set default camera to USA before any map rendering
        let defaultCamera = GMSCameraPosition(latitude: 39.8283, longitude: -98.5795, zoom: 3.5)
        pMapView.camera = defaultCamera

        // ❌ Disable location services to avoid auto-centering
        locationManager.delegate = nil
        locationManager.stopUpdatingLocation()

        pMapView.isMyLocationEnabled = false
        pMapView.settings.myLocationButton = false
        pMapView.delegate = self
    }
    
    override func setUp() { }

    private func bindUI() {
        disposeBag.insert {
            viewModel.geographyRelay
                .skip(1)
                .subscribe(onNext: { [weak self] data in
                    guard let self = self else { return }
                    self.loadMapView(dLat: 39.8283, dLong: -98.5795, zoomLevel: 3.5)
                    self.createNavigationView()
                })

            viewModel.isLoadingRelay
                .subscribe(onNext: { [weak self] isLoading in
                    isLoading ? self?.activityIndicator.startAnimating() : self?.activityIndicator.stopAnimating()
                })
        }
    }

    @IBAction func dateButtonAction(_ sender: Any) {
        let fastisController = FastisController(mode: .range)
        fastisController.initialValue = selectedDateRange
        fastisController.title = "Choose range"
        fastisController.allowToChooseNilDate = true
        fastisController.shortcuts = [.today, .lastWeek]

        fastisController.doneHandler = { date in
            self.selectedDateRange = date

            if let selectedRange = date {
                let fromDateValue = selectedRange.fromDate.formatted(template: "yyyy-MM-dd")
                let toDateValue = selectedRange.toDate.formatted(template: "yyyy-MM-dd")
                self.viewModel.setFromDate(date: fromDateValue)
                self.viewModel.setToDate(date: toDateValue)
                self.viewModel.fetchGeography(fromDate: fromDateValue, toDate: toDateValue)

                DispatchQueue.main.async {
                    self.dateRangeLbl.text = self.displayFormateDate(fromDate: selectedRange.fromDate, toDate: selectedRange.toDate)
                }
            }
        }
        fastisController.present(above: self)
    }

    private func generateClusterItems() {
        guard let geographyRelay = viewModel.geographyRelay.value else { return }
        let kClusterItemCount = geographyRelay.count - 1
        if kClusterItemCount <= 0 { return }

        for index in 0..<kClusterItemCount {
            let lat = Double(geographyRelay[index].attributes?.latitude ?? 0.0)
            let lng = Double(geographyRelay[index].attributes?.longitude ?? 0.0)
            let name = (geographyRelay[index].attributes?.pageviews ?? "") + " pgvs"
            let image = UIImage(named: "pin")!
            let item = POIItems(position: CLLocationCoordinate2DMake(lat, lng), name: name, image: image)
            clusterManager?.add(item)
        }
    }

    func loadMapView(dLat: Double, dLong: Double, zoomLevel: Float) {
        let iconGenerator = GMUDefaultClusterIconGenerator()
        let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
        let renderer = GMUDefaultClusterRenderer(mapView: self.pMapView, clusterIconGenerator: iconGenerator)
        renderer.delegate = self
        self.clusterManager = GMUClusterManager(map: self.pMapView, algorithm: algorithm, renderer: renderer)

        self.generateClusterItems()
        self.clusterManager?.cluster()

        let camera = GMSCameraPosition(latitude: dLat, longitude: dLong, zoom: zoomLevel)
        self.pMapView.camera = camera

        self.clusterManager?.setDelegate(self, mapDelegate: self)
    }

    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {}

    func renderer(_ renderer: GMUClusterRenderer, willRenderMarker marker: GMSMarker) {
        if let markerData = marker.userData, !(markerData is GMUStaticCluster) {
            marker.icon = UIImage(named: "pin")
        }
    }

    func clusterManager(_ clusterManager: GMUClusterManager, didTap cluster: GMUCluster) -> Bool {
        let newCamera = GMSCameraPosition(target: cluster.position, zoom: self.pMapView.camera.zoom + 1, bearing: 0, viewingAngle: 0)
        let update = GMSCameraUpdate.setCamera(newCamera)
        self.pMapView.moveCamera(update)
        return true
    }

    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if let poiItem = marker.userData as? POIItems {
            NSLog("Did tap marker for cluster item \(poiItem.name ?? "N/A")")
            marker.title = poiItem.name
        } else {
            NSLog("Did tap a normal marker")
        }
        return false
    }

    func createNavigationView() {
        DispatchQueue.main.async {
            self.navView = UIView(frame: CGRect(x: self.view.frame.size.width - 120, y: self.pMapView.frame.size.height - 60, width: 115, height: 50))
            self.navView?.backgroundColor = UIColor.white.withAlphaComponent(0.75)
            self.pMapView.addSubview(self.navView!)

            let zoomIn = UIButton(frame: CGRect(x: 10, y: 5, width: 38, height: 38))
            let zoomOut = UIButton(frame: CGRect(x: 65, y: 5, width: 38, height: 38))
            zoomIn.setImage(UIImage(named: "add"), for: .normal)
            zoomOut.setImage(UIImage(named: "minus"), for: .normal)

            zoomIn.contentMode = .scaleAspectFit
            zoomOut.contentMode = .scaleAspectFit

            zoomIn.addTarget(self, action: #selector(self.zoomIn), for: .touchUpInside)
            zoomOut.addTarget(self, action: #selector(self.zoomOut), for: .touchUpInside)

            self.navView?.addSubview(zoomIn)
            self.navView?.addSubview(zoomOut)
        }
    }

    @objc func zoomIn() {
        let currentZoom = pMapView.camera.zoom
        self.pMapView.animate(toZoom: currentZoom + 1)
    }

    @objc func zoomOut() {
        let currentZoom = pMapView.camera.zoom
        self.pMapView.animate(toZoom: currentZoom - 1)
    }

    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 70, height: 30))
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 6

        let lbl1 = UILabel(frame: CGRect(x: 5, y: 2, width: view.frame.size.width - 10, height: 25))
        lbl1.text = marker.title
        lbl1.font = UIFont.ibmMedium(size: 14.0)
        lbl1.numberOfLines = 2
        view.addSubview(lbl1)

        return view
    }
}

class POIItems: NSObject, GMUClusterItem {
    var position: CLLocationCoordinate2D
    var name: String!
    var image: UIImage!

    init(position: CLLocationCoordinate2D, name: String, image: UIImage) {
        self.position = position
        self.name = name
        self.image = image
    }
}

extension MapViewController: StoriesHomeViewModelDelegate {
    func setDateOnUI(toDate: String, fromDate: String) {
        DispatchQueue.main.async {
            self.dateRangeLbl.text = self.setDate(fromDate) + " - " + self.setDate(toDate)
        }
    }

    func setRangeSelection(toDate: Date, fromDate: Date) {
        selectedDateRange = FastisRange(from: fromDate, to: toDate)
    }
}

