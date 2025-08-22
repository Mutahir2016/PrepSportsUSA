//
//  NetworkViewController.swift
//  Lumen
//
//  Created by Syed Mutahir Pirzada on 23/04/2025.
//

import UIKit
import RxCocoa
import Fastis
import RxSwift
import Charts

class NetworkViewController: BaseViewController {
    

    @IBOutlet weak var detailCollectionView: UICollectionView!
    
    
    @IBOutlet weak var topStoriesTable: UITableView!
    @IBOutlet weak var topStoriesBtnView: UIView!
    @IBOutlet weak var noStoriesLabel: UILabel!
    @IBOutlet weak var viewAllStoriesButton: UIButton!
    @IBOutlet weak var topStoriesTblConstraint: NSLayoutConstraint!

    @IBOutlet weak var topLocationTable: UITableView!
    @IBOutlet weak var clicksTable: UITableView!
    @IBOutlet weak var outBoundBtnView: UIView!
    @IBOutlet weak var noOutBoundClicksLabel: UILabel!
    
    @IBOutlet weak var topLocationTblConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var topOrganizationTable: UITableView!
    @IBOutlet weak var topOrganizationTblConstraint: NSLayoutConstraint!
    @IBOutlet weak var topOrgBtnView: UIView!
    @IBOutlet weak var noOrganizationLabel: UILabel!
    
    @IBOutlet weak var topLocButton: UIButton!
    @IBOutlet weak var topOrgButton: UIButton!
    @IBOutlet weak var outBoundClicksButton: UIButton!
    @IBOutlet weak var outBoundsTblConstraint: NSLayoutConstraint!

    @IBOutlet weak var mapsButton: UIButton!

    @IBOutlet weak var impressionsLabel: UILabel!
    @IBOutlet weak var positionLabel: UILabel!
    
    @IBOutlet weak var dateRangeLbl: UILabel!
    var viewModel: NetworkViewModel!
    var router: NetworkRouter!
    
    @IBOutlet weak var tabBarView: UIView!
    @IBOutlet weak var selectDateRangeButton: UIButton!
    @IBOutlet weak var activityIndicator: LoadingIndicatorView!
    @IBOutlet weak var noDataLabel: UILabel!
    
    @IBOutlet weak var graphView: UIView!
    @IBOutlet weak var noChartsLabel: UILabel!
    @IBOutlet weak var graphHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var networkTitleLabel: UILabel!
    @IBOutlet weak var ProjectTitleLabel: UILabel!

    @IBOutlet weak var selectNetworkButton: UIButton!
    @IBOutlet weak var selectProjectButton: UIButton!

    var selectDateRangeAction: Observable<Void> {
        return self.selectDateRangeButton.rx.tap.asObservable()
    }
    
    var selectNetworkAction: Observable<Void> {
        return self.selectNetworkButton.rx.tap.asObservable()
    }
    var selectProjectAction: Observable<Void> {
        return self.selectProjectButton.rx.tap.asObservable()
    }

    var tabBar =  TabBar()
    var selectedDateRange: FastisRange? // Store selected range
    var chartView = LineChartView()
    @IBOutlet weak var topLocBtnView: UIView!
    var detailList = [InfoDataClass] ()
    
    override func callingInsideViewDidLoad() {
        addTabBarView()

        // Your custom logo image
        let logo = UIImage(named: "lumen_logo") // Replace with your logo image
        let profileIcon = UIImage(named: "user") // Replace with your custom image

        // Set up the custom navigation bar with the back button hidden
        setupCustomNavigationBar(
            withLogo: logo,
            rightBarButtonImage: profileIcon,
            rightBarButtonAction: #selector(didTapRightBarButton),
            showBackButton: false // Set to true to show the back button
        )
        
        self.viewModel = NetworkViewModel()
        self.router = NetworkRouter(self)
        registerNibs()
        
        self.noChartsLabel.font = .ibmRegular(size: 14.0)
        self.noStoriesLabel.font = .ibmRegular(size: 14.0)

        viewModel.delegate = self
        viewModel.viewDidLoad()
        setupBindings()
    }
    
    @objc func didTapRightBarButton() {
        print("Right bar button tapped")
        DispatchQueue.main.async {
            self.router?.routeToMore(from: self)
        }
    }
    
    
    private func registerNibs() {
        self.detailCollectionView.register(UINib(nibName: "DetailInfoCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "DetailInfoCollectionViewCell")
        
        self.topLocationTable.register(UINib(nibName: "TopLocationTableCell", bundle: nil), forCellReuseIdentifier: "TopLocationTableCell")
        self.topOrganizationTable.register(UINib(nibName: "TopLocationTableCell", bundle: nil), forCellReuseIdentifier: "TopLocationTableCell")
        self.clicksTable.register(UINib(nibName: "OutBoundTableCell", bundle: nil), forCellReuseIdentifier: "OutBoundTableCell")
        detailCollectionView.register(ShimmerCollectionViewCell.self, forCellWithReuseIdentifier: "ShimmerCell")
        self.topStoriesTable.register(StoriesTableViewCell.nib(), forCellReuseIdentifier: StoriesTableViewCell.className)
    }
    
    // MARK: - Chart Setup Function
    func updateChart(with data: [PageViewData]) {
        // Clear existing charts to prevent overlap
        self.graphView.subviews.forEach { $0.removeFromSuperview() }

        // Configure and add chart
        chartView = LineChartView()
        chartView.translatesAutoresizingMaskIntoConstraints = false
        self.graphView.addSubview(chartView)

        NSLayoutConstraint.activate([
            chartView.leadingAnchor.constraint(equalTo: graphView.leadingAnchor),
            chartView.trailingAnchor.constraint(equalTo: graphView.trailingAnchor),
            chartView.topAnchor.constraint(equalTo: graphView.topAnchor),
            chartView.bottomAnchor.constraint(equalTo: graphView.bottomAnchor)
        ])

        // Prepare data
        var pageviewEntries: [ChartDataEntry] = []
        var uniquePageviewEntries: [ChartDataEntry] = []
        var xLabels: [String] = []

        for (index, pageData) in data.enumerated() {
            xLabels.append(pageData.attributes.formattedDate)
            let pageviews = ChartDataEntry(x: Double(index), y: Double(pageData.attributes.pageviews))
            let uniquePageviews = ChartDataEntry(x: Double(index), y: Double(pageData.attributes.uniquePageviews))
            pageviewEntries.append(pageviews)
            uniquePageviewEntries.append(uniquePageviews)
        }

        // Create data sets
        let pageviewDataSet = LineChartDataSet(entries: pageviewEntries, label: "Pageviews")
        pageviewDataSet.colors = [.appBtnBlueColor]
        pageviewDataSet.circleColors = [.appBtnBlueColor]
        pageviewDataSet.circleRadius = 4.0
        pageviewDataSet.circleHoleRadius = 2.0
        pageviewDataSet.drawValuesEnabled = false

        let uniquePageviewDataSet = LineChartDataSet(entries: uniquePageviewEntries, label: "Unique Pageviews")
        uniquePageviewDataSet.colors = [.appOrangeColor]
        uniquePageviewDataSet.circleColors = [.appOrangeColor]
        uniquePageviewDataSet.circleRadius = 4.0
        uniquePageviewDataSet.circleHoleRadius = 2.0
        uniquePageviewDataSet.drawValuesEnabled = false

        let chartData = LineChartData(dataSets: [pageviewDataSet, uniquePageviewDataSet])
        chartView.data = chartData
        chartView.legend.enabled = false

        // X Axis Configuration
        chartView.xAxis.valueFormatter = CustomXAxisValueFormatter(labels: xLabels)
        chartView.xAxis.labelCount = min(xLabels.count, 6)
        chartView.xAxis.granularity = 1
        chartView.xAxis.labelPosition = .bottom
        chartView.xAxis.drawGridLinesEnabled = false
        chartView.xAxis.labelRotationAngle = -45
        chartView.extraBottomOffset = 0

        // Y Axis
        chartView.rightAxis.enabled = false
        chartView.leftAxis.enabled = true
        chartView.leftAxis.gridLineDashLengths = [4, 4]
        chartView.leftAxis.gridColor = .lightGray
        chartView.leftAxis.gridLineWidth = 0.5
        chartView.delegate = self // Set the delegate
    }
    
    func addTabBarView() {
        let nibName: String = "TabBar"
        tabBar = TabBar(nibName: nibName, bundle: nil)
        tabBar.view.frame = CGRect(x: 0, y: tabBarView.frame.size.height - tabBarView.frame.size.height, width: tabBarView.frame.size.width, height: tabBarView.frame.size.height)
        tabBarView.addSubview(tabBar.view)
        tabBar.setTabBarFor(nTabType: 1)
        tabBar.delegate = self as TabBarDelegate
        dateRangeLbl.font = UIFont.ibmRegular(size: 16.0)
        ProjectTitleLabel.font = UIFont.ibmMedium(size: 16.0)
        networkTitleLabel.font = UIFont.ibmMedium(size: 16.0)
    }
    
    override func setUp() {

    }
    
    private func setupBindings() {
        
        // Bind errors to show error messages
        disposeBag.insert {
            
            viewModel
                .isLoadingRelay
                .subscribe(onNext: { [weak self] isLoading in
                    if isLoading {
                        self?.noDataLabel.isHidden = true
                        self?.activityIndicator.startAnimating()
                    } else {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            self?.activityIndicator.stopAnimating()
                        }
                    }
                })
            
            viewModel
                .shouldShowShimmer
                .subscribe(onNext: { [weak self] show in
                    guard let self = self else { return }
                    self.detailCollectionView.reloadData() // ✅ Reload for both states
                })
            
            viewModel
                .geographyRelay
                .subscribe(onNext: { [weak self] response in
                    guard let self = self else { return }
                    
                    let count = response?.count ?? 0
                    self.topLocationTblConstraint.constant = CGFloat(35 * min(count, 5))
                    topLocBtnView.isHidden = response?.count == 0
                    self.topLocationTable.reloadData()
                })
            
            viewModel.errorSubject
                .subscribe(onNext: { error in
                    // Show error alert
                    print("Error fetching stories: \(error.localizedDescription)")
                })
            
            selectDateRangeAction
                .subscribe(onNext: { [weak self] in
                    guard let self = self else { return }
                    self.showDateRangeSelector()
                })
            
            viewModel.sessionExpiredRelay
                .observe(on: MainScheduler.instance) // Ensure UI updates happen on the main thread
                .subscribe(onNext: { [weak self] in
                    self?.showSessionExpiredAlert()
                })
            
            
            viewModel
                .networkRelay
                .subscribe { [weak self] data in
                    guard let self = self else { return }
                    
                    // If a selected network is already set, just update the label
                    if let selected = self.viewModel.selectedNetwork {
                        self.networkTitleLabel.text = selected.customAttributes.name
                    } else if let firstItem = data?.first {
                        self.viewModel.selectedNetwork = firstItem
                        self.networkTitleLabel.text = firstItem.customAttributes.name
                        RKStorage.shared.saveNetworkData(firstItem, forKey: StoriesHomeKey.network.rawValue)
                    } else {
                        self.networkTitleLabel.text = "No Data Available"
                    }
                }
            
            viewModel
                .projectRelay
                .subscribe { [weak self] data in
                    guard let self = self else { return }
                    
                    if let selected = self.viewModel.selectedProject {
                        self.ProjectTitleLabel.text = selected.customAttributes.name
                    } else if let firstItem = data?.first {
                        self.viewModel.selectedProject = firstItem
                        self.ProjectTitleLabel.text = firstItem.customAttributes.name
                        RKStorage.shared.saveNetworkData(firstItem, forKey: StoriesHomeKey.project.rawValue)
                    } else {
                        self.ProjectTitleLabel.text = "No Data Available"
                    }
                }
            
            viewModel
                .storyRelay
                .subscribe { [weak self] response in
                    guard let self = self else { return }
                    let count = response?.count ?? 0
                    self.topStoriesTblConstraint.constant = CGFloat(113 * min(count, 5))
                    topStoriesBtnView.isHidden = response?.count == 0
                    noStoriesLabel.isHidden = count != 0
                    DispatchQueue.main.async {
                        self.topStoriesTable.reloadData()
                    }
                }
            
            // MARK: - Chart Binding from ViewModel
            viewModel
                .pageViewRelay
                .skip(1)
                .observe(on: MainScheduler.instance)
                .subscribe(onNext: { [weak self] pageViewData in
                    guard let self = self else { return }
                    let hasData = !(pageViewData?.isEmpty ?? true)
                    self.noChartsLabel.isHidden = hasData
                    self.graphHeightConstraint.constant = hasData ? 290 : 100
                    
                    if hasData, let data = pageViewData {
                        self.updateChart(with: data)
                    } else {
                        self.clearChart()
                    }
                })
            
            viewModel
                .shouldPopulatePageViews
                .subscribe(onNext: { [weak self] shouldPopulate in
                    guard let self = self else { return }
                    if shouldPopulate {
                        self.setPageViewDataSet()
                    } else {
                        self.clearChart()
                    }
                })
            
            viewModel
                .topOrganizationsRelay
                .skip(1)
                .subscribe(onNext: { [weak self] response in
                    guard let self = self else { return }
                    let count = response?.data.count ?? 0

                    self.topOrganizationTblConstraint.constant = CGFloat(50 * min(count, 5))
                    topOrgBtnView.isHidden = count == 0
                    noOrganizationLabel.isHidden = count != 0
                    noOrganizationLabel.font = .ibmRegular(size: 14.0)
                    self.topOrganizationTable.reloadData()
                })
            
            viewModel
                .outLinksRelay
                .subscribe(onNext: { [weak self] response in
                    guard let self = self else { return }
                    let count = response?.data.count ?? 0
                    self.outBoundBtnView.isHidden = count == 0
                    self.outBoundsTblConstraint.constant = CGFloat(50 * min(count, 5))
                    self.noOutBoundClicksLabel.isHidden = count != 0
                    self.clicksTable.isHidden = count == 0
                    self.noOutBoundClicksLabel.font = .ibmRegular(size: 14.0)
                    DispatchQueue.main.async {
                        self.clicksTable.reloadData()
                    }
                })
            
            selectNetworkAction
                .subscribe(onNext: { [weak self] in
                    guard let self = self else { return }
                    self.router.presentNetworkSheet(viewModel.networkRelay.value)
                })
            
            selectProjectAction
                .subscribe(onNext: { [weak self] in
                    guard let self = self else { return }
                    self.router.presentProjectSheet(viewModel.projectRelay.value, networkId: nil)
                })
            
            mapsButton
                .rx
                .tap
                .subscribe(onNext: { [weak self] in
                    guard let self = self else { return }
                    self.router.routeToMaps(from: self, for: "\(viewModel.selectedProject?.customAttributes.id ?? 0)", isComingFromNetwork: true)
                })
            
            topLocButton
                .rx
                .tap
                .subscribe(onNext: { [weak self] in
                    guard let self = self else { return }
                    self.router.routeToTopLoc(from: self, for: "\(viewModel.selectedProject?.customAttributes.id ?? 0)", isComingFromNetwork: true)
                })
            
            topOrgButton
                .rx
                .tap
                .subscribe(onNext: { [weak self] in
                    guard let self = self else { return }
                    self.router.routeToTopOrg(from: self, for: "\(viewModel.selectedProject?.customAttributes.id ?? 0)", isComingFromNetwork: true)
                })
            
            outBoundClicksButton
                .rx
                .tap
                .subscribe(onNext: { [weak self] in
                    guard let self = self else { return }
                    self.router.routeToOutboundClicks(from: self,
                                                      for: "\(viewModel.selectedProject?.customAttributes.id ?? 0)",
                                                       isComingFromNetwork: true)
                })

            viewAllStoriesButton
                .rx
                .tap
                .subscribe(onNext: { [weak self] in
                    guard let self = self else { return }
                    self.router.routeToProjectStories(from: self,
                                                      for: Int(viewModel.selectedProject?.id ?? "0") ?? 0)
                })
            
            viewModel
                .indexingRelay
                .subscribe(onNext: { [weak self] response in
                    guard let self = self else { return }
//                    self.populateIndexViewWith(response)
                })
            
            viewModel.errorMessageRelay
                .observe(on: MainScheduler.instance)
                .subscribe(onNext: { [weak self] message in
                    self?.showSessionExpiredAlert()
                })

        }
    }
    
    // MARK: - Optional Cleanup Function (if needed)
    func clearChart() {
        graphView.subviews.forEach { $0.removeFromSuperview() }
    }
        
    private func setPageViewDataSet() {
        
        detailList.removeAll()
        
        let dataSet1 = viewModel.pageViewMetaRelay.value
        let dataSet2 = viewModel.topOrganizationsRelay.value
        let dataSet3 = viewModel.outLinksRelay.value
        
        detailList.append(InfoDataClass(title: "\(formatPageView(dataSet1?.totalPageViews ?? 0))",
                                            detail: "Pageviews",
                                            subtitle: "-",
                                            icon: ""))
            
            detailList.append(InfoDataClass(title: "\(formatPageView(dataSet1?.totalUniquePageViews ?? 0))",
                                            detail: "Unique Pageviews",
                                            subtitle: "-",
                                            icon: ""))
            
            detailList.append(InfoDataClass(title: "\(formatPageView(dataSet3?.meta.totalClicks ?? 0))",
                                            detail: "Outbound Clicks",
                                            subtitle: "-",
                                            icon: ""))
            
            detailList.append(InfoDataClass(title: "\(formatPageView(dataSet2?.meta.totalIdentified ?? 0))",
                                            detail: "Identified\n Organizations",
                                            subtitle: "-",
                                            icon: ""))
        
        detailCollectionView.reloadData()
         
    }
    
    // MARK: Index View Data
    private func populateIndexViewWith( _ data: IndexingData?) {
        guard let data = data else { return }
        
        let impressions = data.attributes.impressions
        let position = data.attributes.positionValue ?? 0.0
        
        impressionsLabel.font = UIFont.ibmBold(size: 22.0)
        positionLabel.font = UIFont.ibmBold(size: 22.0)
        
        impressionsLabel.text = "\(impressions ?? 0)"
        positionLabel.text = String(format: "%.1f", position)
    }
    
    // MARK: Date Range Selector
    
    func showDateRangeSelector() {
        let fastisController = FastisController(mode: .range)
        fastisController.initialValue = selectedDateRange
        
        fastisController.title = "Choose range"
        fastisController.allowToChooseNilDate = true
        fastisController.shortcuts = [.today, .lastWeek, .lastMonth]
        fastisController.doneHandler = { date in
            //
            if let selectedRange = date {
                self.selectedDateRange = selectedRange
                
                print("Selected range: \(selectedRange.fromDate) - \(selectedRange.toDate)")
                let fromDateValue = selectedRange.fromDate.formatted(template: "yyyy-MM-dd")
                let toDateValue = selectedRange.toDate.formatted(template: "yyyy-MM-dd")
                self.viewModel.setFromDate(date: fromDateValue)
                self.viewModel.setToDate(date: toDateValue)
                
                self.noDataLabel.isHidden = true
              
                let selectedProject = RKStorage.shared.getNetwokData(forKey: StoriesHomeKey.project.rawValue, as: NetworkDatum.self)
                
                if let project = selectedProject {
                    self.viewModel.selectedProject = project
                    self.viewModel.reloadProject(project)
                }
                DispatchQueue.main.async {
                    self.dateRangeLbl.text = self.displayFormateDate(fromDate: selectedRange.fromDate, toDate: selectedRange.toDate)
                }
            }
        }
        
        fastisController.present(above: self)
    }
}

extension NetworkViewController {
    private func showSessionExpiredAlert() {
        let alert = UIAlertController(title: "Session Expired", message: "Please login again.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            // Handle logout and navigate to login screen
            self.router?.logoutAndNavigateToSignIn(from: self)
        }))
        present(alert, animated: true)
    }
}


extension NetworkViewController: TabBarDelegate {

    func tabBar(_ tabbar: TabBar, selectedTab nSelectedTab: Int) {
        if nSelectedTab == 2 {
            DispatchQueue.main.async {
                self.router?.routeToStoriesHome(from: self)
            }
        }
        
        if nSelectedTab == 3 {
            print("Search tab of tabbar called")
            DispatchQueue.main.async {
                self.router?.routeToSearch(from: self)
            }
        }
        
        if nSelectedTab == 4 {
            print("Second tab of tabbar called")
            
            DispatchQueue.main.async {
                self.router?.routeToMore(from: self)
            }
        }
    }
}


extension NetworkViewController: StoriesHomeViewModelDelegate {
    func reloadTableData() {
        
    }
    
    func setDateOnUI(toDate: String, fromDate: String) {
        DispatchQueue.main.async {
            self.dateRangeLbl.text = self.setDate(fromDate) + " - " + self.setDate(toDate)
        }
    }
    
    func setRangeSelection(toDate: Date, fromDate: Date) {
        selectedDateRange = FastisRange(from: fromDate, to: toDate)
    }
}

extension NetworkViewController: NetworkSheetViewModelDelegate {
    func projectSheet(_ controller: UIViewController, didSelectProject project: NetworkDatum, projectArr: [NetworkDatum]) {
        print(project)
        RKStorage.shared.saveNetworkData(project, forKey: StoriesHomeKey.project.rawValue)
        self.viewModel.selectedProject = project
        
        DispatchQueue.main.async {
            self.ProjectTitleLabel.text = project.customAttributes.name
        }
        viewModel.hasLoadedAPICalls.toggle()
        viewModel.projectRelay.accept(projectArr)
        viewModel.reloadProject(project)
    }
    
    func networkSheet(_ controller: UIViewController, didSelectNetwork network: NetworkDatum) {
        print(network)
        RKStorage.shared.saveNetworkData(network, forKey: StoriesHomeKey.network.rawValue)
        
        DispatchQueue.main.async {
            self.networkTitleLabel.text = network.customAttributes.name
        }
        self.router.presentProjectSheet(nil, networkId: network.customAttributes.id)
    }
}


extension NetworkViewController: ChartViewDelegate {
    // MARK: - ChartViewDelegate Methods
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        guard let data = viewModel.pageViewRelay.value else { return }
        let index = Int(entry.x)
        if index >= 0 && index < data.count {
            let selectedData = data[index].attributes
            showAnnotation(
                for: selectedData,
                at: CGPoint(x: CGFloat(highlight.xPx), y: CGFloat(highlight.yPx))
            )
        }
    }
    
    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        hideAnnotation()
    }
    
    // MARK: - Annotation View
    // MARK: - Annotation View
    private func showAnnotation(for attributes: PageViewAttributes, at point: CGPoint) {
        // Remove any existing annotation first
        hideAnnotation()

        // Create a new annotation
        let annotation = UILabel()
        annotation.text = """
        Date: \(attributes.formattedDate)
        Pageviews: \(attributes.pageviews)
        Unique Pageviews: \(attributes.uniquePageviews)
        """
        annotation.font = UIFont.systemFont(ofSize: 12)
        annotation.textColor = .white
        annotation.backgroundColor = .black.withAlphaComponent(0.8)
        annotation.numberOfLines = 0
        annotation.textAlignment = .center
        annotation.layer.cornerRadius = 5
        annotation.clipsToBounds = true

        let size = annotation.intrinsicContentSize
        annotation.frame = CGRect(
            x: point.x - size.width / 2,
            y: point.y - size.height - 10,
            width: size.width + 10,
            height: size.height + 5
        )
        annotation.tag = 999 // Tag for easy identification
        chartView.addSubview(annotation)
    }

    private func hideAnnotation() {
        // Remove the annotation by its tag
        chartView.viewWithTag(999)?.removeFromSuperview()
    }
}

extension NetworkViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == topStoriesTable {
            return 113
        } else if tableView == topOrganizationTable {
            return 50
        } else if tableView == clicksTable {
            return 50
        }
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == topStoriesTable {
            if let topStories = viewModel.storyRelay.value {
                return topStories.count
            }
            return 0
        }
        
        if tableView == topLocationTable {
            if let geography = viewModel.geographyRelay.value {
                return geography.count
            }
            return 0
        }
        
        if tableView == topOrganizationTable {
            if let topOrg = viewModel.topOrganizationsRelay.value {
                return topOrg.data.count
            }
            return 0
        }
        
        if tableView == clicksTable {
            if let outLinks = viewModel.outLinksRelay.value {
                return outLinks.data.count
            }
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == topStoriesTable {
            let cell = tableView.dequeueReusableCell(withIdentifier: StoriesTableViewCell.className, for: indexPath) as! StoriesTableViewCell
            cell.selectionStyle = .none
            cell.selectedBackgroundView = UIView() // or nil

            guard let stories = viewModel.storyRelay.value else  { return cell }
            cell.shouldSetLeading = true
            cell.configViewWith(stories[indexPath.row])
            return cell
        }
        
        if tableView == topLocationTable {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TopLocationTableCell", for: indexPath) as! TopLocationTableCell
            
            guard let geography =  viewModel.geographyRelay.value else { return cell }
            
            cell.titleLabel.text = geography[indexPath.row].attributes?.city
            cell.detailLabel.text = geography[indexPath.row].attributes?.pageviews
            
            return cell
        }
        
        else if tableView == topOrganizationTable {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TopLocationTableCell", for: indexPath) as! TopLocationTableCell
            
            guard let topOrg = viewModel.topOrganizationsRelay.value else { return cell }
            let topOrgData = topOrg.data
            cell.titleLabel.text = topOrgData[indexPath.row].attributes.name
            cell.detailLabel.text = topOrgData[indexPath.row].attributes.pageViews
            return cell
        }
        else if tableView == clicksTable {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "OutBoundTableCell", for: indexPath) as! OutBoundTableCell
            
            guard let outLinks =  viewModel.outLinksRelay.value else { return cell }
            let outLinkObj = outLinks.data
            cell.titleLabel.text = outLinkObj[indexPath.row].attributes.outlinkDomain
            cell.detailLabel.text = "\(outLinkObj[indexPath.row].attributes.clicks ?? "0")"
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == topStoriesTable {
            let selectedProject = RKStorage.shared.getNetwokData(forKey: StoriesHomeKey.project.rawValue, as: NetworkDatum.self)
            
            if let project = selectedProject {
                self.viewModel.selectedProject = project
            }
            
            guard let story  = viewModel.storyRelay.value else {return}
                
            let storyId = story[indexPath.row].id
            
            self.router.routeToStoryDetails(storyId)
        }
    }
}

extension NetworkViewController : UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == detailCollectionView {
            return viewModel.shouldShowShimmer.value == true ? 5 : detailList.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == detailCollectionView {
            if viewModel.shouldShowShimmer.value == true {
                print("📌 Showing Shimmer Cell at index \(indexPath.row)")
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ShimmerCell", for: indexPath) as! ShimmerCollectionViewCell
                cell.startShimmer()
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DetailInfoCollectionViewCell" , for: indexPath) as! DetailInfoCollectionViewCell
                
                cell.titleLabel.text = detailList[indexPath.item].title
                cell.detailLbl.text = detailList[indexPath.item].detail
                
                return cell
            }
        }
        return UICollectionViewCell()

    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: UIScreen.main.bounds.width/4, height: 100)
    }
}
