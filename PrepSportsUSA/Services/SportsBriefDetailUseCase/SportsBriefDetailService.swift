//
//  SportsBriefDetailService.swift
//  PrepSportsUSA
//
//  Created by Cascade on 30/08/2025.
//

import Foundation
import RxSwift
import Alamofire

final class SportsBriefDetailService: BaseServiceClass, SportsBriefDetailUseCaseProtocol {
    let client = RKAPIClient.shared
    
    func getPrePitchDetail(id: Int) -> Observable<PrePitchDetailModel?> {
        let path = String(format: Environment.prePitchById, id)
        var request = buildURLRequest(path: path, httpMethod: .get)
        if let token = RKStorage.shared.getSignIn()?.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .appCustomStrategy
        
        return client.requestData(request)
            .do(onNext: { data in
                if let s = String(data: data, encoding: .utf8) { print("Pre-Pitch Detail Raw: \(s)") }
            })
            .decode(type: PrePitchDetailModel?.self, decoder: decoder)
            .catch { error in
                if let customError = error as? CustomError, customError == .sessionExpired {
                    return Observable.error(CustomError.sessionExpired)
                }
                return Observable.error(error)
            }
    }
}
