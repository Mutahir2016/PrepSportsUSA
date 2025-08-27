//
//  SelectTeamViewModel.swift
//  PrepSportsUSA
//
//  Created by PrepSportsUSA on 25/08/2025.
//

import Foundation
import RxSwift
import RxCocoa

protocol SelectTeamViewModelDelegate: AnyObject {
    func reloadTableData()
    func teamSelected(_ team: TeamData)
}

class SelectTeamViewModel: BaseViewModel {
    
    // MARK: - Dependencies
    private let useCase: TeamUseCase
    weak var delegate: SelectTeamViewModelDelegate?
    
    // MARK: - Public Properties
    let isLoadingRelay = BehaviorRelay<Bool>(value: false)
    let sessionExpiredRelay = PublishRelay<Void>()
    
    private(set) var teams: [TeamData] = []
    
    // MARK: - Private Properties
    private var currentSearchQuery: String = ""
    private let pageSize = 20
    private var currentPage = 1
    private var hasMorePages = true
    private var isSearching = false
    
    // Required parameters for team API
    private var organizationId: String = ""
    private var sex: String = ""
    
    // MARK: - Initialization
    init(useCase: TeamUseCase = TeamUseCase(), organizationId: String = "", sex: String = "") {
        self.useCase = useCase
        self.organizationId = organizationId
        self.sex = sex
        super.init()
    }
    
    // MARK: - Public Methods
    func viewDidLoad() {
        loadTeams()
    }
    
    func searchTeams(query: String) {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        currentSearchQuery = trimmedQuery
        isSearching = !trimmedQuery.isEmpty
        
        // Reset pagination for new search
        currentPage = 1
        hasMorePages = true
        
        loadTeams()
    }
    
    func selectTeam(_ team: TeamData) {
        delegate?.teamSelected(team)
    }
    
    func loadMoreIfNeeded(for indexPath: IndexPath) {
        // Load more when reaching near the end of the list
        if indexPath.row >= teams.count - 3 && hasMorePages && !isLoadingRelay.value {
            loadMoreTeams()
        }
    }
    
    func updateParameters(organizationId: String, sex: String) {
        self.organizationId = organizationId
        self.sex = sex
    }
    
    // MARK: - Private Methods
    private func loadTeams() {
        guard !organizationId.isEmpty else {
            print("Missing required parameters: organizationId or sex")
            return
        }
        
        isLoadingRelay.accept(true)
        currentPage = 1
        
        useCase.getTeams(organizationId: organizationId, sex: "", pageSize: pageSize, pageNumber: currentPage)
            .observe(on: MainScheduler.instance)
            .subscribe(
                onNext: { [weak self] response in
                    self?.handleTeamsResponse(response, isLoadMore: false)
                },
                onError: { [weak self] error in
                    self?.handleError(error)
                }
            )
            .disposed(by: disposeBag)
    }
    
    private func loadMoreTeams() {
        guard hasMorePages && !isLoadingRelay.value else { return }
        guard !organizationId.isEmpty && !sex.isEmpty else { return }
        
        isLoadingRelay.accept(true)
        currentPage += 1
        
        useCase.getTeams(organizationId: organizationId, sex: sex, pageSize: pageSize, pageNumber: currentPage)
            .observe(on: MainScheduler.instance)
            .subscribe(
                onNext: { [weak self] response in
                    self?.handleTeamsResponse(response, isLoadMore: true)
                },
                onError: { [weak self] error in
                    self?.handleError(error)
                    self?.currentPage -= 1 // Revert page increment on error
                }
            )
            .disposed(by: disposeBag)
    }
    
    private func handleTeamsResponse(_ response: TeamResponse?, isLoadMore: Bool) {
        isLoadingRelay.accept(false)
        
        guard let response = response else {
            print("No teams response received")
            return
        }
        
        if isLoadMore {
            teams.append(contentsOf: response.data)
        } else {
            teams = response.data
        }
        
        // Check if there are more pages
        hasMorePages = response.data.count == pageSize
        
        delegate?.reloadTableData()
        
        print("Loaded \(response.data.count) teams, total: \(teams.count)")
    }
    
    private func handleError(_ error: Error) {
        isLoadingRelay.accept(false)
        
        if let customError = error as? CustomError, customError == .sessionExpired {
            sessionExpiredRelay.accept(())
        } else {
            print("Teams Error: \(error.localizedDescription)")
            // Could add error handling UI here if needed
        }
    }
}
