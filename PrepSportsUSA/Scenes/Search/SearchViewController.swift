//
//  SearchViewController.swift
//  Lumen
//
//  Created by Assistant on 24/12/2024.
//

import UIKit
import RxSwift
import RxCocoa

class SearchViewController: BaseViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var customSearchBar: CustomSearchBar!
    @IBOutlet weak var searchResultsTableView: UITableView!
    @IBOutlet weak var noResultsLabel: UILabel!
    @IBOutlet weak var tabBarView: UIView!
    @IBOutlet weak var activityIndicator: LoadingIndicatorView!
    
    // MARK: - Properties
    var viewModel: SearchViewModel!
    var router: SearchRouter!
    var tabBar: TabBar!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupRouterAndViewModel()
        setupUI()
        bindViewModel()
        addTabBarView()
    }
    
    private func setupRouterAndViewModel() {
        router = SearchRouter(viewController: self)
        viewModel = SearchViewModel(router: router)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.viewWillAppear()
    }
    
    override func setUp() {
        // Base setup
    }
    
    override func callingInsideViewDidLoad() {
        // Additional setup
    }
    
    // MARK: - Setup
    private func setupUI() {
        title = "Search"
        
        // Setup custom search bar
        customSearchBar.delegate = self
        
        // Setup table view
        searchResultsTableView.isHidden = true
        searchResultsTableView.rowHeight = UITableView.automaticDimension
        searchResultsTableView.estimatedRowHeight = 133
        searchResultsTableView.separatorStyle = .none
        searchResultsTableView.keyboardDismissMode = .onDrag
        
        // Register custom cell
        searchResultsTableView.register(StoriesTableViewCell.nib(), forCellReuseIdentifier: StoriesTableViewCell.className)
        
        // Setup no results label
        noResultsLabel.text = "No stories found for your search"
        noResultsLabel.textAlignment = .center
        noResultsLabel.isHidden = true
        noResultsLabel.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        noResultsLabel.textColor = .secondaryLabel
        
        // Setup navigation
        setupCustomNavigationBar(
            withLogo: UIImage(named: "lumen_logo"),
            showBackButton: false
        )
    }
    
    private func bindViewModel() {
        // Bind loading state to activity indicator
        viewModel.isLoading
            .subscribe(onNext: { [weak self] isLoading in
                if isLoading {
                    self?.noResultsLabel.isHidden = true
                    self?.activityIndicator.startAnimating()
                } else {
                    self?.activityIndicator.stopAnimating()
                }
            })
            .disposed(by: disposeBag)
        
        // Bind search results to table view
        viewModel.searchResults
            .bind(to: searchResultsTableView.rx.items(cellIdentifier: StoriesTableViewCell.className)) { [weak self] row, story, cell in
                if let storiesCell = cell as? StoriesTableViewCell {
                    self?.configureStoriesCell(storiesCell, with: story)
                }
            }
            .disposed(by: disposeBag)
        
        // Bind loading state (show table when not loading and has results)
        Observable.combineLatest(viewModel.isLoading, viewModel.hasResults)
            .map { isLoading, hasResults in
                return !(!isLoading && hasResults)
            }
            .bind(to: searchResultsTableView.rx.isHidden)
            .disposed(by: disposeBag)
        
        // Bind no results state (show when not loading, search text is not empty, and no results)
        Observable.combineLatest(viewModel.isLoading, viewModel.hasResults, viewModel.searchText)
            .map { isLoading, hasResults, searchText in
                // Hide the label when: loading, has results, or search text is empty
                // Show the label when: not loading AND no results AND search text is not empty
                let shouldShowNoResults = !isLoading && !hasResults && !searchText.isEmpty
                return !shouldShowNoResults // isHidden = true when we DON'T want to show it
            }
            .bind(to: noResultsLabel.rx.isHidden)
            .disposed(by: disposeBag)
        
        // Note: We don't bind text automatically anymore - only update on search
        
        // Bind error messages
        viewModel.errorMessage
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] errorMessage in
                self?.showErrorAlert(message: errorMessage)
            })
            .disposed(by: disposeBag)
        
        // Handle table view selection
        searchResultsTableView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                guard let self = self,
                      let story = self.viewModel.searchResults.value[safe: indexPath.row] else { return }
                self.searchResultsTableView.deselectRow(at: indexPath, animated: true)
                self.viewModel.didSelectStory(story)
            })
            .disposed(by: disposeBag)
        
        // Handle infinite scrolling
        searchResultsTableView.rx.willDisplayCell
            .subscribe(onNext: { [weak self] (cell, indexPath) in
                guard let self = self else { return }
                let totalRows = self.viewModel.searchResults.value.count
                if indexPath.row >= totalRows - 3 && self.viewModel.hasMorePages.value {
                    self.viewModel.loadMoreResults()
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func configureStoriesCell(_ cell: StoriesTableViewCell, with story: SearchStoryItem) {
        // Convert SearchStoryItem to Story format and use existing cell configuration
        let storyData = story.toStoryModel()
        cell.configViewWith(storyData)
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func addTabBarView() {
        let nibName: String = "TabBar"
        tabBar = TabBar(nibName: nibName, bundle: nil)
        tabBar.view.frame = CGRect(x: 0, y: tabBarView.frame.size.height - tabBarView.frame.size.height, width: tabBarView.frame.size.width, height: tabBarView.frame.size.height)
        tabBarView.addSubview(tabBar.view)
        tabBar.setTabBarFor(nTabType: 5) // Set to 5 for search tab
        tabBar.delegate = self as TabBarDelegate
    }
}

// MARK: - CustomSearchBarDelegate
extension SearchViewController: CustomSearchBarDelegate {
    func customSearchBar(_ searchBar: CustomSearchBar, didSearchWith text: String) {
        viewModel.performSearch(with: text)
    }
}

// MARK: - TabBarDelegate
extension SearchViewController: TabBarDelegate {
    func tabBar(_ tabbar: TabBar, selectedTab nSelectedTab: Int) {
        if nSelectedTab == 1 {
            DispatchQueue.main.async {
                self.router?.routeToNetwork(from: self)
            }
        }
        
        if nSelectedTab == 2 {
            print("Stories tab of tabbar called")
            DispatchQueue.main.async {
                self.router.popViewController(from: self)
            }
        }
        
        if nSelectedTab == 3 {
            print("Search tab of tabbar called")
            DispatchQueue.main.async {
                self.router?.routeToSearch(from: self)
            }
        }
        
        if nSelectedTab == 4 {
            print("More tab of tabbar called")
            DispatchQueue.main.async {
                self.router?.routeToMore(from: self)
            }
        }
    }
}



// MARK: - Array Extension for Safe Access
extension Array {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
} 
