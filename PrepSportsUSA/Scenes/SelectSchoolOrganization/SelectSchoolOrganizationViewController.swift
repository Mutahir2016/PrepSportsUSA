//
//  SelectSchoolOrganizationViewController.swift
//  PrepSportsUSA
//
//  Created by PrepSportsUSA on 25/08/2025.
//

import UIKit
import RxSwift
import RxCocoa
import Foundation

class SelectSchoolOrganizationViewController: BaseViewController {
    var viewModel: SelectSchoolOrganizationViewModel!
    var router: SelectSchoolOrganizationRouter!
    
    @IBOutlet weak var searchTextField: UITextField!
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
        viewModel = SelectSchoolOrganizationViewModel()
        viewModel.delegate = self
        router = SelectSchoolOrganizationRouter(self)
    }
    
    private func setupUI() {
        title = "Select School Organization"
        view.backgroundColor = UIColor.systemBackground
        
        setupSearchField()
        setupTableView()
        setupNavigationBar()
    }
    
    private func setupSearchField() {
        searchTextField.placeholder = "Search"
        searchTextField.borderStyle = .roundedRect
        searchTextField.font = UIFont.systemFont(ofSize: 16)
        searchTextField.clearButtonMode = .whileEditing
        
        // Add search icon
        let searchIcon = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        searchIcon.tintColor = UIColor.systemGray
        searchIcon.contentMode = .scaleAspectFit
        let iconContainer = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 20))
        searchIcon.frame = CGRect(x: 5, y: 0, width: 20, height: 20)
        iconContainer.addSubview(searchIcon)
        searchTextField.rightView = iconContainer
        searchTextField.rightViewMode = .always
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .singleLine
        tableView.backgroundColor = UIColor.systemBackground
        tableView.rowHeight = 60
        
        // Register cell
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SchoolCell")
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
        
        // Bind search text
        searchTextField.rx.text.orEmpty
            .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] searchText in
                self?.viewModel.searchSchools(query: searchText)
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

// MARK: - SelectSchoolOrganizationViewModelDelegate
extension SelectSchoolOrganizationViewController: SelectSchoolOrganizationViewModelDelegate {
    func reloadTableData() {
        tableView.reloadData()
    }
    
    func schoolSelected(_ school: SchoolOrganizationData) {
        router.dismissWithSelection(school)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension SelectSchoolOrganizationViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.filteredSchools.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SchoolCell", for: indexPath)
        
        let school = viewModel.filteredSchools[indexPath.row]
        cell.textLabel?.text = school.attributes.name
        cell.textLabel?.font = UIFont.systemFont(ofSize: 16)
        cell.accessoryType = .none
        cell.selectionStyle = .default
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let school = viewModel.filteredSchools[indexPath.row]
        viewModel.selectSchool(school)
    }
}
