//
//  AddSportsBriefViewController.swift
//  PrepSportsUSA
//
//  Created by PrepSportsUSA on 25/08/2025.
//

import UIKit
import RxSwift
import RxCocoa

class AddSportsBriefViewController: BaseViewController {
    var viewModel: AddSportsBriefViewModel!
    var router: AddSportsBriefRouter!
    
    @IBOutlet weak var schoolOrganizationButton: UIButton!
    
    private var selectedSchoolOrganization: SchoolOrganizationData?
    
    override func callingInsideViewDidLoad() {
        setupViewModelAndRouter()
        setupUI()
        setupActions()
    }
    
    override func setUp() {
        
    }
    
    private func setupViewModelAndRouter() {
        viewModel = AddSportsBriefViewModel()
        router = AddSportsBriefRouter(self)
    }
    
    private func setupUI() {
        title = "Add Sports Brief"
        updateSchoolOrganizationButton()
    }
    
    private func setupActions() {
        schoolOrganizationButton.addTarget(self, action: #selector(schoolOrganizationButtonTapped), for: .touchUpInside)
    }
    
    @objc private func schoolOrganizationButtonTapped() {
        router.navigateToSelectSchoolOrganization()
    }
    
    func didSelectSchoolOrganization(_ school: SchoolOrganizationData) {
        selectedSchoolOrganization = school
        updateSchoolOrganizationButton()
    }
    
    private func updateSchoolOrganizationButton() {
        if let school = selectedSchoolOrganization {
            schoolOrganizationButton.setTitle(school.attributes.name, for: .normal)
            schoolOrganizationButton.setTitleColor(UIColor.label, for: .normal)
        } else {
            schoolOrganizationButton.setTitle("Select School Organization", for: .normal)
            schoolOrganizationButton.setTitleColor(UIColor.placeholderText, for: .normal)
        }
    }
}
