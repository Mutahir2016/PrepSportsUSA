//
//  StoriesHomeViewController.swift
//  Lumen
//
//  Created by Syed Mutahir Pirzada on 11/01/2025.
//

import UIKit
import RxCocoa
import Fastis
import RxSwift

class StoriesHomeViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var dateRangeLbl: UILabel!
    var viewModel: StoriesHomeViewModel!
    var router: StoriesHomeRouter!
    
    @IBOutlet weak var tabBarView: UIView!
    @IBOutlet weak var selectDateRangeButton: UIButton!
    @IBOutlet weak var activityIndicator: LoadingIndicatorView!
    @IBOutlet weak var noDataLabel: UILabel!
    @IBOutlet weak var sortByButton: UIButton!
    
    @IBOutlet weak var sortByLbl: UILabel!
    @IBOutlet weak var sortByTitleLbl: UILabel!
    var selectDateRangeAction: Observable<Void> {
        return self.selectDateRangeButton.rx.tap.asObservable()
    }
    var sortByButtonAction: Observable<Void> {
        return self.sortByButton.rx.tap.asObservable()
    }
    
    var tabBar =  TabBar()
    var selectedDateRange: FastisRange? // Store selected range

    override func callingInsideViewDidLoad() {
        addTabBarView()
        setupBindings()
        tableView.register(StoriesTableViewCell.nib(), forCellReuseIdentifier: StoriesTableViewCell.className)
        noDataLabel.isHidden = true
                
        // Your custom logo
        let logo = UIImage(named: "lumen_logo") // Replace with your logo image
        
        // Your custom right bar button image
        let profileIcon = UIImage(named: "user") // Replace with your custom image
        
        // Set up the custom navigation bar
        setupCustomNavigationBar2(
            withLogo: logo,
            rightBarButtonImage: profileIcon,
            rightBarButtonAction: #selector(didTapRightBarButton),
            showBackButton: false
        )
        
        sortByLbl.font = UIFont.ibmRegular(size: 14.0)
        sortByTitleLbl.font = UIFont.ibmRegular(size: 14.0)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.viewModel.viewDidLoad()
    }
    
    @objc func didTapRightBarButton() {
        print("Right bar button tapped")
        DispatchQueue.main.async {
            self.router?.routeToMore(from: self)
        }
    }
    
    override func setUp() {
        viewModel = StoriesHomeViewModel()
        router = StoriesHomeRouter(self)
        
        viewModel.delegate = self
       
    }
    
    private func setupBindings() {
        
        let accType = RKStorage.shared.getUserProfile()?.data.attributes.accountType ?? ""
        if accType == "story_watcher" {
            viewModel.sortOptionsArr = ["Traffic", "Published by Asc", "Published by Desc"]
            sortByTitleLbl.text = "Traffic"
        } else {
            viewModel.sortOptionsArr = ["Published by Asc", "Published by Desc"]
            sortByTitleLbl.text = "Published by Asc"
        }
        
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
            
            sortByButtonAction.subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.showSortActionSheet()
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
        tabBar.setTabBarFor(nTabType: 2)
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

extension StoriesHomeViewController: StoriesHomeViewModelDelegate {
    func reloadTableData() {
        DispatchQueue.main.async {
            if self.viewModel.stories.isEmpty {
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

extension StoriesHomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.stories.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 113
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: StoriesTableViewCell.className, for: indexPath) as! StoriesTableViewCell
        if viewModel.stories.count > 0 {
            let story = viewModel.stories[indexPath.row]
            cell.configViewWith(story)
        }
        
        
        // Trigger pagination
        if indexPath.row == viewModel.stories.count - 1 && viewModel.currentPage < viewModel.totalRecords - 1 {
            viewModel.currentPage += 1
            
            self.viewModel.fetchStories(fromDate: viewModel.getFromDate() ?? "",
                                        toDate: viewModel.getToDate() ?? "")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if viewModel.stories.count > 0 {
            let storyId = viewModel.stories[indexPath.row].id
            router?.routeToStoryDetails(storyId)
        }
    }
}

extension StoriesHomeViewController: TabBarDelegate {
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


extension StoriesHomeViewController {
    private func showSessionExpiredAlert() {
        let alert = UIAlertController(title: "Session Expired", message: "Please login again.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            // Handle logout and navigate to login screen
            self.router?.logoutAndNavigateToSignIn(from: self)
        }))
        present(alert, animated: true)
    }
}

extension StoriesHomeViewController {
    
    private func showSortActionSheet() {
        let alertController = UIAlertController(title: "Sort By", message: nil, preferredStyle: .actionSheet)
        
        for (index, option) in viewModel.sortOptionsArr.enumerated() {
            let action = UIAlertAction(title: option, style: .default) { _ in
                print("Selected: \(option) at index \(index)") // Handle selection with index
                let accType = RKStorage.shared.getUserProfile()?.data.attributes.accountType ?? ""
                self.sortByTitleLbl.text = self.viewModel.sortOptionsArr[index]

                if accType == "story_watcher" {
                    switch index {
                    case 0:
                        self.viewModel.sortBy = nil
                    case 1:
                        self.viewModel.sortBy = "published_at"
                        case 2:
                        self.viewModel.sortBy = "-published_at"
                     default:
                        break
                    }
                    
                    self.viewModel.viewDidLoad()
                } else {
                    
                    switch index {
                    case 0:
                        self.viewModel.sortBy = "published_at"
                    case 1:
                        self.viewModel.sortBy = "-published_at"
                    default:
                       break
                    }
                    self.viewModel.viewDidLoad()
                }
            }
            alertController.addAction(action)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
}
