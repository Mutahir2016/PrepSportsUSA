//
//  ProjectStoriesViewController.swift
//  Lumen
//
//  Created by Syed Mutahir Pirzada on 17/06/2025.
//

import UIKit
import RxCocoa
import Fastis
import RxSwift

class ProjectStoriesViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var dateRangeLbl: UILabel!
    var viewModel: ProjectStoriesViewModel!
    var router: ProjectStoriesRouter!
    
    @IBOutlet weak var tabBarView: UIView!
    @IBOutlet weak var selectDateRangeButton: UIButton!
    @IBOutlet weak var activityIndicator: LoadingIndicatorView!
    @IBOutlet weak var noDataLabel: UILabel!
    
    var selectDateRangeAction: Observable<Void> {
        return self.selectDateRangeButton.rx.tap.asObservable()
    }
    var tabBar =  TabBar()
    var selectedDateRange: FastisRange? // Store selected range

    override func callingInsideViewDidLoad() {
        addTabBarView()
        setupBindings()
        
        self.tableView.register(StoriesTableViewCell.nib(), forCellReuseIdentifier: StoriesTableViewCell.className)

        noDataLabel.isHidden = true
        viewModel.delegate = self
        viewModel.viewDidLoad()
        dateRangeLbl.font = UIFont.ibmRegular(size: 16.0)

        self.title = "Stories"
    }
    
    override func setUp() {
        router = ProjectStoriesRouter(self)
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
                        self?.activityIndicator.stopAnimating()
                    }
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
        }
    }
    
    func addTabBarView() {
        let nibName: String = "TabBar"
        tabBar = TabBar(nibName: nibName, bundle: nil)
        tabBar.view.frame = CGRect(x: 0, y: tabBarView.frame.size.height - tabBarView.frame.size.height, width: tabBarView.frame.size.width, height: tabBarView.frame.size.height)
        tabBarView.addSubview(tabBar.view)
        tabBar.setTabBarFor(nTabType: 1)
        tabBar.delegate = self as TabBarDelegate
    }
    
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
                self.viewModel.fetchStories(fromDate: fromDateValue, toDate: toDateValue)
                
                DispatchQueue.main.async {
                    self.dateRangeLbl.text = self.displayFormateDate(fromDate: selectedRange.fromDate, toDate: selectedRange.toDate)
                }
            }
        }
        
        fastisController.present(above: self)
    }
}

extension ProjectStoriesViewController: StoriesHomeViewModelDelegate {
    func reloadTableData() {
        DispatchQueue.main.async {
            if self.viewModel.storiesArr.isEmpty {
                self.noDataLabel.isHidden = false
            } else {
                self.noDataLabel.isHidden = true
            }
            self.tableView.reloadData()
        }
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

extension ProjectStoriesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.storiesArr.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 113.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: StoriesTableViewCell.className, for: indexPath) as! StoriesTableViewCell
        let story = viewModel.storiesArr[indexPath.row]
        cell.selectionStyle = .none

        cell.configViewWith(story)
        // Trigger pagination
        if indexPath.row == viewModel.storiesArr.count - 1 && viewModel.currentPage < viewModel.totalRecords - 1 {
            viewModel.currentPage += 1
            
            self.viewModel.fetchStories(fromDate: viewModel.getFromDate() ?? "",
                                        toDate: viewModel.getToDate() ?? "")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let story = viewModel.storiesArr[indexPath.row]
        router.routeToStoryDetails(story.id)
//        let storyId = viewModel.topOutlinkArr[indexPath.row].id
//        router?.routeToStoryDetails(storyId)
    }

}

extension ProjectStoriesViewController: TabBarDelegate {
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


extension ProjectStoriesViewController {
    private func showSessionExpiredAlert() {
        let alert = UIAlertController(title: "Session Expired", message: "Please login again.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            // Handle logout and navigate to login screen
            self.router?.logoutAndNavigateToSignIn(from: self)
        }))
        present(alert, animated: true)
    }
}
