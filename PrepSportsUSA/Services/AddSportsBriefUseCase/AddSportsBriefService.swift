//
//  AddSportsBriefService.swift
//  PrepSportsUSA
//
//  Created by PrepSportsUSA on 25/08/2025.
//

import Foundation
import RxSwift
import Alamofire

class AddSportsBriefService: BaseServiceClass, AddSportsBriefUseCaseProtocol {
    
    let client = RKAPIClient.shared
    
    func submitSportsBrief(title: String, description: String) -> Observable<Bool> {
        // For now, return a mock successful response
        // You can implement the actual API call later when needed
        
        print("Submit Sports Brief - Title: \(title)")
        print("Submit Sports Brief - Description: \(description)")
        
        // Simulate API delay
        return Observable.just(true)
            .delay(.seconds(2), scheduler: MainScheduler.instance)
            .do(onNext: { success in
                print("Sports brief submission \(success ? "successful" : "failed")")
            })
    }
}
