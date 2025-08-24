//
//  SelectSchoolOrganizationViewModel.swift
//  PrepSportsUSA
//
//  Created by PrepSportsUSA on 25/08/2025.
//

import Foundation
import RxSwift
import RxCocoa

protocol SelectSchoolOrganizationViewModelDelegate: AnyObject {
    func reloadTableData()
    func schoolSelected(_ school: SchoolOrganizationData)
}

class SelectSchoolOrganizationViewModel: BaseViewModel {
    
    // MARK: - Dependencies
    private let useCase: SchoolOrganizationUseCase
    weak var delegate: SelectSchoolOrganizationViewModelDelegate?
    
    // MARK: - Public Properties
    let isLoadingRelay = BehaviorRelay<Bool>(value: false)
    let sessionExpiredRelay = PublishRelay<Void>()
    
    private(set) var allSchools: [SchoolOrganizationData] = []
    private(set) var filteredSchools: [SchoolOrganizationData] = []
    
    // MARK: - Private Properties
    private var currentSearchQuery: String = ""
    private let pageSize = 20
    private var currentPage = 1
    private var hasMorePages = true
    
    // MARK: - Initialization
    init(useCase: SchoolOrganizationUseCase = SchoolOrganizationUseCase()) {
        self.useCase = useCase
        super.init()
    }
    
    // MARK: - Public Methods
    func viewDidLoad() {
        loadSchoolOrganizations()
    }
    
    func searchSchools(query: String) {
        currentSearchQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        filterSchools()
    }
    
    func selectSchool(_ school: SchoolOrganizationData) {
        delegate?.schoolSelected(school)
    }
    
    func loadMoreIfNeeded(for indexPath: IndexPath) {
        // Load more when reaching near the end of the list
        if indexPath.row >= filteredSchools.count - 3 && hasMorePages && !isLoadingRelay.value {
            loadMoreSchools()
        }
    }
    
    // MARK: - Private Methods
    private func loadSchoolOrganizations() {
        isLoadingRelay.accept(true)
        currentPage = 1
        
        useCase.getSchoolOrganizations(pageSize: pageSize, pageNumber: currentPage)
            .observe(on: MainScheduler.instance)
            .subscribe(
                onNext: { [weak self] response in
                    self?.handleSchoolOrganizationsResponse(response, isLoadMore: false)
                },
                onError: { [weak self] error in
                    self?.handleError(error)
                }
            )
            .disposed(by: disposeBag)
    }
    
    private func loadMoreSchools() {
        guard hasMorePages && !isLoadingRelay.value else { return }
        
        isLoadingRelay.accept(true)
        currentPage += 1
        
        useCase.getSchoolOrganizations(pageSize: pageSize, pageNumber: currentPage)
            .observe(on: MainScheduler.instance)
            .subscribe(
                onNext: { [weak self] response in
                    self?.handleSchoolOrganizationsResponse(response, isLoadMore: true)
                },
                onError: { [weak self] error in
                    self?.handleError(error)
                    self?.currentPage -= 1 // Revert page increment on error
                }
            )
            .disposed(by: disposeBag)
    }
    
    private func handleSchoolOrganizationsResponse(_ response: SchoolOrganizationResponse?, isLoadMore: Bool) {
        isLoadingRelay.accept(false)
        
        guard let response = response else {
            print("No school organizations response received")
            return
        }
        
        if isLoadMore {
            allSchools.append(contentsOf: response.data)
        } else {
            allSchools = response.data
        }
        
        // Check if there are more pages
        hasMorePages = response.data.count == pageSize
        
        filterSchools()
        delegate?.reloadTableData()
        
        print("Loaded \(response.data.count) schools, total: \(allSchools.count)")
    }
    
    private func filterSchools() {
        if currentSearchQuery.isEmpty {
            filteredSchools = allSchools
        } else {
            filteredSchools = allSchools.filter { school in
                school.attributes.name.localizedCaseInsensitiveContains(currentSearchQuery)
            }
        }
        delegate?.reloadTableData()
    }
    
    private func handleError(_ error: Error) {
        isLoadingRelay.accept(false)
        
        if let customError = error as? CustomError, customError == .sessionExpired {
            sessionExpiredRelay.accept(())
        } else {
            print("School Organizations Error: \(error.localizedDescription)")
            // Could add error handling UI here if needed
        }
    }
}
