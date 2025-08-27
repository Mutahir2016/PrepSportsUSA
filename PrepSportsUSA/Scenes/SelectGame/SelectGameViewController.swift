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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: GameSelectionTableViewCell.identifier, for: indexPath) as? GameSelectionTableViewCell else {
            return UITableViewCell()
        }
        
        let game = viewModel.games[indexPath.row]
        cell.configure(with: game)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let game = viewModel.games[indexPath.row]
        viewModel.selectGame(game)
    }
}
