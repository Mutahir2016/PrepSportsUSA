//
//  SelectGameViewModel.swift
//  PrepSportsUSA
//
//  Created by PrepSportsUSA on 25/08/2025.
//

import Foundation
import RxSwift
import RxCocoa

protocol SelectGameViewModelDelegate: AnyObject {
    func reloadTableData()
    func gameSelected(_ game: GameData)
}

class SelectGameViewModel: BaseViewModel {
    
    // MARK: - Dependencies
    private let useCase: GameUseCase
    weak var delegate: SelectGameViewModelDelegate?
    
    // MARK: - Public Properties
    let isLoadingRelay = BehaviorRelay<Bool>(value: false)
    let sessionExpiredRelay = PublishRelay<Void>()
    
    private(set) var games: [GameData] = []
    
    // MARK: - Private Properties
    private let pageSize = 20
    private var currentPage = 1
    private var hasMorePages = true
    
    // Required parameter for games API
    private var teamId: String = ""
    
    // MARK: - Initialization
    init(useCase: GameUseCase = GameUseCase(), teamId: String = "") {
        self.useCase = useCase
        self.teamId = teamId
        super.init()
    }
    
    // MARK: - Public Methods
    func viewDidLoad() {
        loadGames()
    }
    
    func selectGame(_ game: GameData) {
        delegate?.gameSelected(game)
    }
    
    func loadMoreIfNeeded(for indexPath: IndexPath) {
        // Load more when reaching near the end of the list
        if indexPath.row >= games.count - 3 && hasMorePages && !isLoadingRelay.value {
            loadMoreGames()
        }
    }
    
    func updateTeamId(_ teamId: String) {
        self.teamId = teamId
    }
    
    // MARK: - Private Methods
    private func loadGames() {
        guard !teamId.isEmpty else {
            print("Missing required parameter: teamId")
            return
        }
        
        isLoadingRelay.accept(true)
        currentPage = 1
        
        useCase.getGames(teamId: teamId, pageSize: pageSize, pageNumber: currentPage)
            .observe(on: MainScheduler.instance)
            .subscribe(
                onNext: { [weak self] response in
                    self?.handleGamesResponse(response, isLoadMore: false)
                },
                onError: { [weak self] error in
                    self?.handleError(error)
                }
            )
            .disposed(by: disposeBag)
    }
    
    private func loadMoreGames() {
        guard hasMorePages && !isLoadingRelay.value else { return }
        guard !teamId.isEmpty else { return }
        
        isLoadingRelay.accept(true)
        currentPage += 1
        
        useCase.getGames(teamId: teamId, pageSize: pageSize, pageNumber: currentPage)
            .observe(on: MainScheduler.instance)
            .subscribe(
                onNext: { [weak self] response in
                    self?.handleGamesResponse(response, isLoadMore: true)
                },
                onError: { [weak self] error in
                    self?.handleError(error)
                    self?.currentPage -= 1 // Revert page increment on error
                }
            )
            .disposed(by: disposeBag)
    }
    
    private func handleGamesResponse(_ response: GameResponse?, isLoadMore: Bool) {
        isLoadingRelay.accept(false)
        
        guard let response = response else {
            print("No games response received")
            return
        }
        
        if isLoadMore {
            games.append(contentsOf: response.data)
        } else {
            games = response.data
        }
        
        // Check if there are more pages
        hasMorePages = response.data.count == pageSize
        
        delegate?.reloadTableData()
        
        print("Loaded \(response.data.count) games, total: \(games.count)")
    }
    
    private func handleError(_ error: Error) {
        isLoadingRelay.accept(false)
        
        if let customError = error as? CustomError, customError == .sessionExpired {
            sessionExpiredRelay.accept(())
        } else {
            print("Games Error: \(error.localizedDescription)")
            // Could add error handling UI here if needed
        }
    }
}
