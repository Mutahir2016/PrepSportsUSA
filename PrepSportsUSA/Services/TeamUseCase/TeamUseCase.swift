//
//  TeamUseCase.swift
//  PrepSportsUSA
//
//  Created by PrepSportsUSA on 25/08/2025.
//

import Foundation
import RxSwift

protocol TeamUseCaseProtocol {
    func getTeams(organizationId: String, sex: String, pageSize: Int, pageNumber: Int) -> Observable<TeamResponse?>
}

class TeamUseCase: TeamUseCaseProtocol {
    private let service: TeamService
    
    init(service: TeamService = TeamService()) {
        self.service = service
    }
    
    func getTeams(organizationId: String, sex: String, pageSize: Int, pageNumber: Int) -> Observable<TeamResponse?> {
        return service.getTeams(organizationId: organizationId, sex: sex, pageSize: pageSize, pageNumber: pageNumber)
    }
}
