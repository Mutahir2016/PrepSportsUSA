//
//  SportsBriefDetailUseCase.swift
//  PrepSportsUSA
//
//  Created by Cascade on 30/08/2025.
//

import Foundation
import RxSwift

protocol SportsBriefDetailUseCaseProtocol {
    func getPrePitchDetail(id: Int) -> Observable<PrePitchDetailModel?>
}

final class SportsBriefDetailUseCase {
    private let service: SportsBriefDetailUseCaseProtocol
    
    init(service: SportsBriefDetailUseCaseProtocol = SportsBriefDetailService()) {
        self.service = service
    }
    
    func fetchPrePitchDetail(id: Int) -> Observable<PrePitchDetailModel?> {
        return service.getPrePitchDetail(id: id)
    }
}

// MARK: - Detail Response Model
struct PrePitchDetailModel: Codable {
    let data: PrePitchData
}
