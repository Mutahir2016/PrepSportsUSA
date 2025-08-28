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
    
    // No games found label
    private var noGamesLabel: UILabel!
    
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
        setupNoGamesLabel()
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor.systemGroupedBackground
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 88

        // Register custom cell
        let nib = UINib(nibName: "GameSelectionTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: GameSelectionTableViewCell.identifier)
    }
    
    private func setupNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelButtonTapped)
        )
    }
    
    private func setupNoGamesLabel() {
        noGamesLabel = UILabel()
        noGamesLabel.text = "No games found"
        noGamesLabel.font = UIFont(name: "IBMPlexSans-Medium", size: 16) ?? UIFont.systemFont(ofSize: 16, weight: .medium)
        noGamesLabel.textColor = UIColor.label
        noGamesLabel.textAlignment = .center
        noGamesLabel.isHidden = true
        noGamesLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(noGamesLabel)
        
        NSLayoutConstraint.activate([
            noGamesLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noGamesLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
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
            noGamesLabel.isHidden = true
        } else {
            activityIndicator.stopAnimating()
            updateNoGamesLabelVisibility()
        }
    }
    
    private func updateNoGamesLabelVisibility() {
        let hasGames = viewModel.games.count > 0
        noGamesLabel.isHidden = hasGames
        tableView.isHidden = !hasGames
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
        updateNoGamesLabelVisibility()
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: GameSelectionTableViewCell.identifier, for: indexPath) as? GameSelectionTableViewCell else {
            return UITableViewCell()
        }
        
        let game = viewModel.games[indexPath.row]
        cell.configure(with: game, currentTeamId: viewModel.getCurrentTeamId())
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let game = viewModel.games[indexPath.row]
        viewModel.selectGame(game)
    }
}
