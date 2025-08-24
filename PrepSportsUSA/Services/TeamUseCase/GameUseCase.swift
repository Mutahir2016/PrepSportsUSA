//
//  GameUseCase.swift
//  PrepSportsUSA
//
//  Created by PrepSportsUSA on 25/08/2025.
//

import Foundation
import RxSwift

protocol GameUseCaseProtocol {
    func getGames(teamId: String, pageSize: Int, pageNumber: Int) -> Observable<GameResponse?>
}

class GameUseCase: GameUseCaseProtocol {
    private let service: GameService
    
    init(service: GameService = GameService()) {
        self.service = service
    }
    
    func getGames(teamId: String, pageSize: Int, pageNumber: Int) -> Observable<GameResponse?> {
        return service.getGames(teamId: teamId, pageSize: pageSize, pageNumber: pageNumber)
    }
}
