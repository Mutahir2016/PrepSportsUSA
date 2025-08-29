//
//  SportsViewController.swift
//  PrepSportsUSA
//
//  Created by PrepSportsUSA on 22/08/2025.
//

import UIKit
import RxSwift
import RxCocoa

class SportsViewController: BaseViewController {
    var viewModel: SportsViewModel!
    var router: SportsRouter!
    var tabBar =  TabBar()

    @IBOutlet weak var tabBarView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: LoadingIndicatorView!

    override func callingInsideViewDidLoad() {
        setupViewModelAndRouter()
        setupNavigationBar()
        addTabBarView()
        setupTableView()
        bindViewModel()
        viewModel.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Refresh data when returning to this view to show new sports briefs
        viewModel.refreshData()
    }
    
    override func setUp() {
        
    }
    
    private func setupViewModelAndRouter() {
        viewModel = SportsViewModel()
        viewModel.delegate = self
        router = SportsRouter(self)
    }
    
    private func setupNavigationBar() {
        // Hide the back button to prevent overlap with logo
        navigationItem.hidesBackButton = true
        navigationItem.leftBarButtonItem = nil
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor.systemGroupedBackground
        
        // Register the cell
        let nib = UINib(nibName: "SportsTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: SportsTableViewCell.identifier)
        
        // Add pull to refresh
        setupPullToRefresh()
    }
    
    private func setupPullToRefresh() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    @objc private func refreshData() {
        viewModel.refreshData()
    }
    
    @IBAction func addBriefAction() {
        router.routeToAddSportsBriefs()
    }
    
    private func bindViewModel() {
        // Bind loading state
        viewModel.isLoadingRelay
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isLoading in
                self?.handleLoadingState(isLoading)
            })
            .disposed(by: disposeBag)
        
        // Bind session expiration
        viewModel.sessionExpiredRelay
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                self?.showSessionExpiredAlert()
            })
            .disposed(by: disposeBag)
    }
    
    private func handleLoadingState(_ isLoading: Bool) {
        if isLoading {
            print("Loading pre pitches data...")
            activityIndicator.startAnimating()
        } else {
            print("Finished loading data")
            activityIndicator.stopAnimating()
            tableView.refreshControl?.endRefreshing()
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
}


extension SportsViewController: TabBarDelegate {
    func tabBar(_ tabbar: TabBar, selectedTab nSelectedTab: Int) {
        
        if nSelectedTab == 2 {
            DispatchQueue.main.async {
                self.router?.routeToStoriesHome(from: self)
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

extension SportsViewController: SportsViewModelDelegate {
    func reloadTableData() {
        tableView.reloadData()
    }
}

extension SportsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.prePitches.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SportsTableViewCell.identifier, for: indexPath) as! SportsTableViewCell
        
        let prePitch = viewModel.prePitches[indexPath.row]
        let attributes = prePitch.attributes
        
        // Map data to match Android format exactly
        let title = attributes.name ?? "Pre-Pitch"
        let teamName = attributes.payload?.limparTeam?.name ?? attributes.payload?.limparGame?.homeTeam?.name ?? "Team"
        
        // Extract actual team names from the game
        let homeTeamName = attributes.payload?.limparGame?.homeTeam?.name ?? "Home Team"
        let awayTeamName = attributes.payload?.limparGame?.awayTeam?.name ?? "Away Team"
        
        // Extract scores from boxscore if available
        let sport = attributes.payload?.limparTeam?.sport?.lowercased() ?? ""
        let homeScore = extractScore(from: attributes.payload?.boxscore?.homeTeam, sport: sport)
        let awayScore = extractScore(from: attributes.payload?.boxscore?.awayTeam, sport: sport)
        
        // Build display sport and date
        let displaySport = (attributes.payload?.limparTeam?.sport ?? "").capitalized
        let rawDate = attributes.payload?.limparGame?.dateTime
        let formattedDate = formatGameDate(rawDate)

        let matchData = SportsMatchData(
            title: title,
            subtitle: teamName,
            homeTeam: homeTeamName,
            awayTeam: awayTeamName,
            homeScore: homeScore,
            awayScore: awayScore,
            sport: displaySport,
            dateTime: formattedDate
        )
        
        cell.configure(with: matchData)
        
        // Debug logging
        print("Cell \(indexPath.row): \(title)")
        print("Total items: \(viewModel.prePitches.count), hasLoaded: \(viewModel.hasLoaded)")
        
        // Trigger pagination - load more when reaching near the end
        if indexPath.row == viewModel.prePitches.count - 1 && !viewModel.hasLoaded {
            print("Triggering load more data...")
            viewModel.loadMoreData()
        }
        
        return cell
    }
    
    // Helper function to extract score from boxscore
    private func extractScore(from teamScore: [String: AnyCodable]?, sport: String) -> Int {
        guard let teamScore = teamScore else {
            print("No team score data available")
            return 0
        }
        
        // Debug: Print all available keys and values
        print("Sport: \(sport)")
        print("Available boxscore keys and values:")
        for (key, value) in teamScore {
            print("  \(key): \(value.value) (type: \(type(of: value.value)))")
        }
        
        // Golf typically doesn't have traditional scores - return 0
        if sport.contains("golf") {
            print("Golf detected - returning 0 for score")
            return 0
        }
        
        // Read final score from boxscore data
        // Football uses 'final', other sports use 'final_score'
        let scoreKey = sport.contains("football") ? "final" : "final_score"
        
        if let finalScore = teamScore[scoreKey]?.value as? Int {
            print("Found \(scoreKey) (int): \(finalScore)")
            return finalScore
        }
        
        if let finalScore = teamScore[scoreKey]?.value as? String, let score = Int(finalScore) {
            print("Found \(scoreKey) (string): \(score)")
            return score
        }
        
        print("No \(scoreKey) found, returning 0")
        return 0
    }
    
    // Format ISO date string (e.g., 2025-08-15T19:00:00Z) to "Aug 15, 2025 @ 7:00 PM"
    private func formatGameDate(_ isoString: String?) -> String? {
        guard let isoString = isoString, !isoString.isEmpty else { return nil }
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        var date = isoFormatter.date(from: isoString)
        if date == nil {
            // Try without fractional seconds
            let altFormatter = ISO8601DateFormatter()
            altFormatter.formatOptions = [.withInternetDateTime]
            date = altFormatter.date(from: isoString)
        }
        guard let date = date else { return nil }
        let out = DateFormatter()
        out.locale = Locale(identifier: "en_US_POSIX")
        out.dateFormat = "MMM d, yyyy @ h:mm a"
        return out.string(from: date)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let prePitch = viewModel.prePitches[indexPath.row]
        let id = prePitch.attributes.id
        router.routeToSportsBriefDetail(prePitchId: id)
    }
}

// MARK: - Session Expiration Handling
extension SportsViewController {
    private func showSessionExpiredAlert() {
        let alert = UIAlertController(title: "Session Expired", message: "Please login again.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            // Handle logout and navigate to login screen
            self.router?.logoutAndNavigateToSignIn(from: self)
        }))
        present(alert, animated: true, completion: nil)
    }
}

