//
//  SelectGameViewController.swift
//  PrepSportsUSA
//
//  Created by PrepSportsUSA on 25/08/2025.
//

import UIKit
import RxSwift
import RxCocoa
import Foundation

class SelectGameViewController: BaseViewController {
    var viewModel: SelectGameViewModel!
    var router: SelectGameRouter!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: LoadingIndicatorView!
    
    override func callingInsideViewDidLoad() {
        setupViewModelAndRouter()
        setupUI()
        bindViewModel()
        viewModel.viewDidLoad()
    }
    
    override func setUp() {
        
    }
    
    private func setupViewModelAndRouter() {
        // View model should be set by the router when navigating
        if viewModel == nil {
            viewModel = SelectGameViewModel()
        }
        viewModel.delegate = self
        router = SelectGameRouter(self)
    }
    
    private func setupUI() {
        title = "Select Game"
        view.backgroundColor = UIColor.systemBackground
        
        setupTableView()
        setupNavigationBar()
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .singleLine
        tableView.backgroundColor = UIColor.systemBackground
        tableView.rowHeight = UITableView.automaticDimension
        tableView.rowHeight = UITableView.automaticDimension

        // Register cell
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "GameCell")
    }
    
    private func setupNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelButtonTapped)
        )
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
        
        // Handle pagination - load more when scrolling near the end
        tableView.rx.willDisplayCell
            .subscribe(onNext: { [weak self] (cell, indexPath) in
                self?.viewModel.loadMoreIfNeeded(for: indexPath)
            })
            .disposed(by: disposeBag)
    }
    
    private func handleLoadingState(_ isLoading: Bool) {
        if isLoading {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }
    
    @objc private func cancelButtonTapped() {
        router.dismiss()
    }
    
    private func showSessionExpiredAlert() {
        let alert = UIAlertController(title: "Session Expired", message: "Please login again.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            self.router.logoutAndNavigateToSignIn()
        }))
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - SelectGameViewModelDelegate
extension SelectGameViewController: SelectGameViewModelDelegate {
    func reloadTableData() {
        tableView.reloadData()
    }
    
    func gameSelected(_ game: GameData) {
        router.dismissWithSelection(game)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension SelectGameViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.games.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GameCell", for: indexPath)
        
        let game = viewModel.games[indexPath.row]
        
        // Format the game display text
        let homeTeam = game.attributes.homeTeam.name
        let awayTeam = game.attributes.awayTeam.name
        let venue = game.attributes.venue
        
        // Format date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "MMM dd, yyyy"
        
        var dateString = ""
        if let date = dateFormatter.date(from: game.attributes.dateTime) {
            dateString = displayFormatter.string(from: date)
        }
        
        cell.textLabel?.text = "\(homeTeam) vs \(awayTeam)"
        cell.detailTextLabel?.text = "\(venue) • \(dateString)"
        cell.textLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 14)
        cell.detailTextLabel?.textColor = UIColor.systemGray
        cell.accessoryType = .none
        cell.selectionStyle = .default
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let game = viewModel.games[indexPath.row]
        viewModel.selectGame(game)
    }
}
