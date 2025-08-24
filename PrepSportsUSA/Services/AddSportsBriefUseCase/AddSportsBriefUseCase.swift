//
//  AddSportsBriefUseCase.swift
//  PrepSportsUSA
//
//  Created by PrepSportsUSA on 25/08/2025.
//

import Foundation
import RxSwift

protocol AddSportsBriefUseCaseProtocol {
    func submitSportsBrief(title: String, description: String) -> Observable<Bool>
}

class AddSportsBriefUseCase: AddSportsBriefUseCaseProtocol {
    private let service: AddSportsBriefService
    
    init(service: AddSportsBriefService = AddSportsBriefService()) {
        self.service = service
    }
    
    func submitSportsBrief(title: String, description: String) -> Observable<Bool> {
        return service.submitSportsBrief(title: title, description: description)
    }
}
