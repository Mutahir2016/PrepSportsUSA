//
//  StoriesViewController.swift
//  Lumen
//
//  Created by Syed Mutahir Pirzada on 04/01/2025.
//

import UIKit
import Fastis
import Charts
import RxSwift

class StoriesViewController: BaseViewController {
    
    @IBOutlet weak var headlineLabel: UILabel!
    
    @IBOutlet weak var infoCollectionView: UICollectionView!
    @IBOutlet weak var detailCollectionView: UICollectionView!
    
    @IBOutlet weak var topLocationTable: UITableView!
    @IBOutlet weak var topOrganizationTable: UITableView!
    @IBOutlet weak var clicksTable: UITableView!
    
    @IBOutlet weak var dateRangeLbl: UILabel!
    @IBOutlet weak var graphView: UIView!
    @IBOutlet weak var impressionsLabel: UILabel!
    @IBOutlet weak var positionLabel: UILabel!
    @IBOutlet weak var activityIndicator: LoadingIndicatorView!
    @IBOutlet weak var topLocationTblConstraint: NSLayoutConstraint!
    @IBOutlet weak var topOrganizationTblConstraint: NSLayoutConstraint!
    @IBOutlet weak var outBoundsTblConstraint: NSLayoutConstraint!
    @IBOutlet weak var topLocButton: UIButton!
    @IBOutlet weak var topOrgButton: UIButton!
    @IBOutlet weak var outBoundClicksButton: UIButton!
    @IBOutlet weak var mapsButton: UIButton!

    @IBOutlet weak var topLocBtnView: UIView!
    @IBOutlet weak var topOrgBtnView: UIView!
    @IBOutlet weak var outBoundBtnView: UIView!

    @IBOutlet weak var noOutBoundClicksLabel: UILabel!
    @IBOutlet weak var noOrganizationLabel: UILabel!

    var infoList = [InfoDataClass] ()
    var detailList = [InfoDataClass] ()
    
    @IBOutlet weak var tabBarView: UIView!
    var tabBar =  TabBar()
    var viewModel: StoriesViewModel!
    var router: StoriesRouter!
    
    let chartView = LineChartView()
    var selectedDateRange: FastisRange? // Store selected range

    override func callingInsideViewDidLoad() {
        bindUIWithData()
        addTabBarView()
        registerNibs()
        // Your custom logo image
        let logo = UIImage(named: "lumen_logo") // Replace with your logo image
        let profileIcon = UIImage(named: "user") // Replace with your custom image

        // Set up the custom navigation bar with the back button hidden
        setupCustomNavigationBar(
            withLogo: logo,
            rightBarButtonImage: profileIcon,
            rightBarButtonAction: #selector(didTapRightBarButton),
            showBackButton: true // Set to true to show the back button
        )
        
        // Do any additional setup after loading the view.
       
        if let flowLayout = infoCollectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        }
    }
    
    @objc func didTapRightBarButton() {
        print("Right bar button tapped")
        DispatchQueue.main.async {
            self.router?.routeToMore(from: self)
        }
    }
    
    private func registerNibs() {
        self.infoCollectionView.register(UINib(nibName: "InfoCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "InfoCollectionViewCell")
        self.detailCollectionView.register(UINib(nibName: "DetailInfoCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "DetailInfoCollectionViewCell")
        
        self.topLocationTable.register(UINib(nibName: "TopLocationTableCell", bundle: nil), forCellReuseIdentifier: "TopLocationTableCell")
        self.topOrganizationTable.register(UINib(nibName: "TopLocationTableCell", bundle: nil), forCellReuseIdentifier: "TopLocationTableCell")
        self.clicksTable.register(UINib(nibName: "OutBoundTableCell", bundle: nil), forCellReuseIdentifier: "OutBoundTableCell")
        detailCollectionView.register(ShimmerCollectionViewCell.self, forCellWithReuseIdentifier: "ShimmerCell")

    }
    
    
    // MARK: Chart View Data set
    func updateChart(with data: [PageViewData]) {
        
        chartView.frame = CGRect(x: 0, y: 0, width: self.graphView.frame.size.width, height: self.graphView.frame.size.height)
        chartView.delegate = self // Set the delegate
        self.graphView.addSubview(chartView)
        
        var pageviewEntries: [ChartDataEntry] = []
        var uniquePageviewEntries: [ChartDataEntry] = []
        var xLabels: [String] = []

        for (index, pageData) in data.enumerated() {
            // Extract data for x-axis and y-axis
            xLabels.append(pageData.attributes.formattedDate)
            let pageviews = ChartDataEntry(x: Double(index), y: Double(pageData.attributes.pageviews))
            let uniquePageviews = ChartDataEntry(x: Double(index), y: Double(pageData.attributes.uniquePageviews))
            pageviewEntries.append(pageviews)
            uniquePageviewEntries.append(uniquePageviews)
        }

        // Set up datasets
        let pageviewDataSet = LineChartDataSet(entries: pageviewEntries, label: "Pageviews")
        pageviewDataSet.colors = [.appBtnBlueColor]
        pageviewDataSet.circleColors = [.appBtnBlueColor]
        pageviewDataSet.circleRadius = 4.0
        pageviewDataSet.circleHoleRadius = 2.0

        let uniquePageviewDataSet = LineChartDataSet(entries: uniquePageviewEntries, label: "Unique Pageviews")
        uniquePageviewDataSet.colors = [.appOrangeColor]
        uniquePageviewDataSet.circleColors = [.appOrangeColor]
        uniquePageviewDataSet.circleRadius = 4.0
        uniquePageviewDataSet.circleHoleRadius = 2.0

        // Assign data to chart
        let chartData = LineChartData(dataSets: [pageviewDataSet, uniquePageviewDataSet])
        chartView.data = chartData
        chartView.legend.enabled = false
        
        // Customize X-Axis
        chartView.xAxis.valueFormatter = CustomXAxisValueFormatter(labels: xLabels)
        chartView.xAxis.labelCount = min(xLabels.count, 6) // Reduce clutter
        chartView.xAxis.granularity = 1 // Ensure labels are evenly spaced
        chartView.xAxis.labelPosition = .bottom // Place x-axis labels at the bottom
        chartView.xAxis.drawGridLinesEnabled = false // No vertical grid lines
        chartView.xAxis.labelRotationAngle = -45 // Tilt labels

        // Add extra padding to avoid label cutting
        chartView.extraBottomOffset = 0 // Add enough space for labels
        
        chartView.rightAxis.enabled = false // Disable the right axis
        chartView.leftAxis.enabled = true // Ensure the left axis remains enabled

        // Customize horizontal grid lines to be dotted
        chartView.leftAxis.gridLineDashLengths = [4, 4] // Dotted line (4 points drawn, 4 points skipped)
        chartView.leftAxis.gridColor = .lightGray // Optional: Set the color of the grid lines
        chartView.leftAxis.gridLineWidth = 0.5 // Optional: Adjust the line width
    }

    func addTabBarView() {
        let nibName: String = "TabBar"
        tabBar = TabBar(nibName: nibName, bundle: nil)
        tabBar.view.frame = CGRect(x: 0, y: tabBarView.frame.size.height - tabBarView.frame.size.height, width: tabBarView.frame.size.width, height: tabBarView.frame.size.height)
        tabBarView.addSubview(tabBar.view)
        tabBar.setTabBarFor(nTabType: 2)
        tabBar.delegate = self as TabBarDelegate
        
    }

    override func setUp() {
        router = StoriesRouter(self)
        
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
                self.selectedDateRange = selectedRange
                
                print("Selected range: \(selectedRange.fromDate) - \(selectedRange.toDate)")
                let fromDateValue = selectedRange.fromDate.formatted(template: "yyyy-MM-dd")
                let toDateValue = selectedRange.toDate.formatted(template: "yyyy-MM-dd")
                self.viewModel.setFromDate(date: fromDateValue)
                self.viewModel.setToDate(date: toDateValue)
                
                self.viewModel.fetchStories(fromDate: fromDateValue, toDate: toDateValue)
                
                DispatchQueue.main.async {
                    self.dateRangeLbl.text = self.displayFormateDate(fromDate: selectedRange.fromDate, toDate: selectedRange.toDate)
                }
            }
        }
        fastisController.present(above: self)
    }
    
    private func bindUIWithData() {
        disposeBag.insert {
            viewModel
                .isLoadingRelay
                .subscribe(onNext: { [weak self] isLoading in
                    if isLoading {
                        self?.activityIndicator.startAnimating()
                    } else {
                        self?.activityIndicator.stopAnimating()
                    }
                })
            
            viewModel
                .storyRelay
                .subscribe(onNext: { [weak self] response in
                    guard let self = self else { return }
                    self.populateStoryViewWith(response)
                }
            )
            
            viewModel
                .pageViewRelay
                       .compactMap { $0 }
                       .subscribe(onNext: { [weak self] pageViewData in
                           guard let self = self else { return }
                           self.updateChart(with: pageViewData)
                       })
            viewModel
                .geographyRelay
                .subscribe(onNext: { [weak self] response in
                    guard let self = self else { return }
                    self.topLocationTblConstraint.constant = CGFloat(50 * (response?.count ?? 0))
                    topLocBtnView.isHidden = response?.count == 0

                    self.topLocationTable.reloadData()
                })
            
            viewModel
                .shouldPopulatePageViews
                .subscribe(onNext: { [weak self] shouldPopulate in
                    guard let self = self else { return }
                    if shouldPopulate {
                        self.setPageViewDataSet()
                    }
                })
            
            viewModel
                .outLinksRelay
                .subscribe(onNext: { [weak self] response in
                    guard let self = self else { return }
                    let count = response?.data.count ?? 0
                    outBoundBtnView.isHidden = count == 0
                    outBoundsTblConstraint.constant = CGFloat(50 * min(count, 5))
                    noOutBoundClicksLabel.isHidden = count != 0
                    clicksTable.isHidden = count == 0
                    noOutBoundClicksLabel.font = .ibmRegular(size: 14.0)
                    self.clicksTable.reloadData()
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
                .indexingRelay
                .subscribe(onNext: { [weak self] response in
                    guard let self = self else { return }
                    self.populateIndexViewWith(response)
                })
            
            viewModel
                .shouldShowShimmer
                .subscribe(onNext: { [weak self] show in
                    guard let self = self else { return }
                    self.detailCollectionView.reloadData() // ✅ Reload for both states
                })
            
            viewModel.sessionExpiredRelay
                        .observe(on: MainScheduler.instance) // Ensure UI updates happen on the main thread
                        .subscribe(onNext: { [weak self] in
                            self?.showSessionExpiredAlert()
                        })
            
            topLocButton
                .rx
                .tap
                .subscribe(onNext: { [weak self] in
                    guard let self = self else { return }
                    self.router.routeToTopLoc(viewModel.storyId.value)
                })
            
            topOrgButton
                .rx
                .tap
                .subscribe(onNext: { [weak self] in
                    guard let self = self else { return }
                    self.router.routeToTopOrg(viewModel.storyId.value)
                })
            outBoundClicksButton
                .rx
                .tap
                .subscribe(onNext: { [weak self] in
                    guard let self = self else { return }
                    self.router.routeToOutboundClicks(viewModel.storyId.value)
                })
            
            mapsButton
                .rx
                .tap
                .subscribe(onNext: { [weak self] in
                    guard let self = self else { return }
                    self.router.routeToMaps(viewModel.storyId.value)
                })
        }
    }
    
    
    // MARK: Story View Data
    private func populateStoryViewWith(_ data: StoryModelData?) {
        guard let data = data else { return }
        let storyData = data.attributes
        
        headlineLabel.text = storyData.headline
        
        let published = storyData.publishedAt?.formatted(template: "MMM dd, YYYY") ?? "-"
        let pitched = storyData.pitchDate?.formatted(template: "MMM dd, YYYY") ?? "-"
        
        infoList.append(InfoDataClass(title: "Published \(published)", detail: "", subtitle: "", icon: "File"))
        infoList.append(InfoDataClass(title: "Pitched \(pitched)", detail: "", subtitle: "", icon: "LinktreeLogo"))
        infoList.append(InfoDataClass(title: storyData.project ?? "", detail: "", subtitle: "", icon: "Article"))
        
        infoCollectionView.reloadData()
    }
    
    private func setPageViewDataSet() {
        
        let dataSet1 = viewModel.storyRelay.value
        let dataSet2 = viewModel.topOrganizationsRelay.value
        let dataSet3 = viewModel.outLinksRelay.value
        
        if let dataSetOne = dataSet1, let dataSetTwo = dataSet2, let dataSetThree = dataSet3 {
            detailList.append(InfoDataClass(title: "\(formatPageView(dataSetOne.attributes.pageviews ?? 0))",
                                            detail: "Pageviews",
                                            subtitle: "-",
                                            icon: ""))
            detailList.append(InfoDataClass(title: "\(formatPageView(dataSetOne.attributes.uniquePageviews ?? 0))",
                                            detail: "Unique Pageviews",
                                            subtitle: "-",
                                            icon: ""))
            detailList.append(InfoDataClass(title: "\(getFormattedTime(dataSetOne.attributes.averageTime ?? 0))",
                                            detail: "Avg. Time on Page",
                                            subtitle: "-",
                                            icon: ""))
            detailList.append(InfoDataClass(title: "\(formatPageView(dataSetThree.meta.totalClicks ?? 0))",
                                            detail: "Outbound Clicks",
                                            subtitle: "-",
                                            icon: ""))
            
            detailList.append(InfoDataClass(title: "\(formatPageView(dataSetTwo.meta.totalIdentified))",
                                            detail: "Identified\n Organizations",
                                            subtitle: "-",
                                            icon: ""))
            detailList.append(InfoDataClass(title: "\(formatPageView(dataSetTwo.meta.totalUnIdentified))",
                                            detail: "Unidentified\n Organizations",
                                            subtitle: "-",
                                            icon: ""))
        }
        
        detailCollectionView.reloadData()
    }
    
    
    // MARK: Index View Data
    private func populateIndexViewWith( _ data: IndexingData?) {
        
        positionLabel.text = "-"
        impressionsLabel.text = "-"
        
        guard let data = data else { return }
        
        let impressions = data.attributes.impressions ?? 0
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        let formattedImpression = numberFormatter.string(from: NSNumber(value: impressions)) ?? "0"
        
        let position = data.attributes.positionValue ?? 0.0
        
        impressionsLabel.font = UIFont.ibmBold(size: 22.0)
        positionLabel.font = UIFont.ibmBold(size: 22.0)
        
        impressionsLabel.text = "\(formattedImpression)"
        positionLabel.text = String(format: "%.1f", position)
    }
}

extension StoriesViewController : UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == detailCollectionView {
            return viewModel.shouldShowShimmer.value == true ? 5 : detailList.count
        } else {
            return infoList.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == infoCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "InfoCollectionViewCell" , for: indexPath) as! InfoCollectionViewCell
            
            cell.titleLabel.text = infoList[indexPath.item].title
            cell.iconView.image = UIImage(named: infoList[indexPath.item].icon)
            
            return cell
        }
        
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
        
        if collectionView == infoCollectionView {
            return CGSize(width: UIScreen.main.bounds.width / 1.5, height: 16)
        } else if collectionView == detailCollectionView {
            return CGSize(width: UIScreen.main.bounds.width / 3.9, height: 90)
        }
        
        // ✅ Return a default size to handle any other collectionViews
        return CGSize(width: 100, height: 100)
    }

}

extension StoriesViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == topLocationTable || tableView == topOrganizationTable || tableView ==  clicksTable {
            return 50.0
        }
        
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == topLocationTable {
            if let geography = viewModel.geographyRelay.value  {
                return geography.count
            }
            return 0
        }
        
        if tableView == topOrganizationTable {
            if let topOrg = viewModel.topOrganizationsRelay.value  {
                return min(topOrg.data.count, 5)
            }
            return 0
        }
        
        if let outLinks = viewModel.outLinksRelay.value  {
            return min(outLinks.data.count, 5)
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == topLocationTable {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TopLocationTableCell", for: indexPath) as! TopLocationTableCell
            
            guard let geography =  viewModel.geographyRelay.value else { return cell }
            
            cell.configView(geography[indexPath.row])
            cell.separatorView.isHidden = (indexPath.row == geography.count - 1)

            return cell
        }
        else if tableView == topOrganizationTable {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TopLocationTableCell", for: indexPath) as! TopLocationTableCell
            
            guard let topOrg = viewModel.topOrganizationsRelay.value else { return cell }
            let topOrgData = topOrg.data
            cell.configView(topOrgData[indexPath.row])
            cell.separatorView.isHidden = (indexPath.row == topOrgData.count - 1)
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "OutBoundTableCell", for: indexPath) as! OutBoundTableCell
        
        guard let outLinks =  viewModel.outLinksRelay.value else { return cell }
        let outLinkObj = outLinks.data[indexPath.row]
        cell.configView(outLinkObj)
        cell.separatorView.isHidden = (indexPath.row == outLinks.data.count - 1)

        return cell
    }
}


extension StoriesViewController: TabBarDelegate {

    func tabBar(_ tabbar: TabBar, selectedTab nSelectedTab: Int) {
        if nSelectedTab == 1 {
            DispatchQueue.main.async {
                self.router?.routeToNetwork(from: self)
            }
        }
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

extension StoriesViewController: ChartViewDelegate {
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


class CustomXAxisValueFormatter: IndexAxisValueFormatter {
    private var labels: [String]

    init(labels: [String]) {
        self.labels = labels
        super.init()
    }

    override func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let index = Int(value)
        // Show one date per month or skip dates based on granularity
        if index % 5 == 0, index < labels.count {
            return labels[index]
        }
        return ""
    }
}


extension StoriesViewController {
    private func showSessionExpiredAlert() {
        let alert = UIAlertController(title: "Session Expired", message: "Please login again.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            // Handle logout and navigate to login screen
            self.router?.logoutAndNavigateToSignIn(from: self)
        }))
        present(alert, animated: true)
    }
}

extension StoriesViewController: StoriesHomeViewModelDelegate {
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
