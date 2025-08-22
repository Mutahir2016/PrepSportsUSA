//
//  NetworkSheetViewController.swift
//  Lumen
//
//  Created by Syed Mutahir Pirzada on 27/04/2025.
//

import UIKit

import UIKit
import MaterialComponents.MaterialTextControls_FilledTextFields
import MaterialComponents.MaterialTextControls_OutlinedTextFields

class NetworkSheetViewController: BaseViewController {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var searchTextField: MDCOutlinedTextField!
    @IBOutlet var tableView: UITableView!
    var originalProjects: [NetworkDatum] = [] // Full list (ProjectDatum = your project model)
    var filteredProjects: [NetworkDatum] = [] // Filtered list based on search
    
    var viewModel: NetworkSheetViewModel!
    
    override func callingInsideViewDidLoad() {
        
        titleLabel.font = UIFont.ibmMedium(size: 18.0)
        
        searchTextField.label.text = "Search"
        searchTextField.placeholder = "Type something..."
        
        let searchIcon = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        searchIcon.tintColor = .darkGray  // <-- set the icon color
        
        searchTextField.leadingView = searchIcon
        searchTextField.leadingViewMode = .always
        
        searchTextField.setOutlineColor(.gray, for: .normal)
        searchTextField.setOutlineColor(.blue, for: .editing)
        
        searchTextField.setNormalLabelColor(.gray, for: .normal)
        searchTextField.setFloatingLabelColor(.blue, for: .editing)
        
        searchTextField.setTextColor(.darkGray, for: .normal)
        
        tableView.register(SheetTableCell.nib(), forCellReuseIdentifier: SheetTableCell.className)
        
        searchTextField.addTarget(self, action: #selector(searchTextChanged(_:)), for: .editingChanged)
        bindUI()
    }
    
    func bindUI() {
        viewModel
            .networkRelay
            .subscribe(onNext: { [weak self] projects in
                guard let self = self else { return }
                self.originalProjects = projects ?? []
                self.filteredProjects = self.originalProjects
                self.tableView.reloadData()
            })
            .disposed(by: disposeBag)
    }
    
    @objc private func searchTextChanged(_ textField: UITextField) {
        guard let searchText = textField.text?.lowercased(), !searchText.isEmpty else {
            // Empty search, show all
            filteredProjects = originalProjects
            tableView.reloadData()
            return
        }
        
        // Filter projects
        filteredProjects = originalProjects.filter { project in
            project.customAttributes.name.lowercased().contains(searchText)
        }
        tableView.reloadData()
    }
    
    override func setUp() {
        
    }
}

extension NetworkSheetViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredProjects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SheetTableCell.className, for: indexPath) as! SheetTableCell
        let project = filteredProjects[indexPath.row]
        
        cell.titleLabel.text = project.customAttributes.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let project = filteredProjects[indexPath.row]
        self.dismiss(animated: true) {
            self.viewModel.delegate?.networkSheet(self, didSelectNetwork: project)
        }
    }
}
