//
//  SportsUseCase.swift
//  PrepSportsUSA
//
//  Created by PrepSportsUSA on 23/08/2025.
//

import Foundation
import RxSwift

protocol SportsUseCaseProtocol {
    func getPrePitches(pageSize: Int, pageNumber: Int) -> Observable<PrePitchesModel?>
}

class SportsUseCase {
    let disposeBag: DisposeBag = DisposeBag()
    private var service: SportsUseCaseProtocol
    
    init(service: SportsService = SportsService()) {
        self.service = service
    }
    
    func fetchPrePitches(pageSize: Int, pageNumber: Int) -> Observable<PrePitchesModel?> {
        return service.getPrePitches(pageSize: pageSize, pageNumber: pageNumber)
    }
}
