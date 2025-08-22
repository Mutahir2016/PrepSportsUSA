//
//  SearchService.swift
//  Lumen
//
//  Created by Assistant on 24/12/2024.
//

import Foundation
import RxSwift
import Alamofire

// MARK: - Search Response Models
struct SearchStoriesResponse: Codable {
    let data: [StoryModelData]
    let links: Links
    let meta: SearchMeta?
}

struct SearchMeta: Codable {
    let pagination: SearchPagination
}

struct SearchPagination: Codable {
    let current: Int
    let records: Int
}

class SearchService: BaseServiceClass {
    
    let client = RKAPIClient.shared
    
    func searchStories(query: String, pageNumber: Int = 1, pageSize: Int = 20) -> Observable<SearchStoriesResponse> {
        let parameters: [String: Any] = [
            "query": query,
            "pageNumber": pageNumber,
            "pageSize": pageSize
        ]
        
        var request = buildURLRequest(path: Environment.searchStories,
                                     httpMethod: .get,
                                     parameters: parameters)
        
        request.setValue("Bearer \(RKStorage.shared.getSignIn()?.token ?? "")", forHTTPHeaderField: "Authorization")
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .appCustomStrategy
        
        return client.requestData(request)
            .do(onNext: { data in
                if let responseString = String(data: data, encoding: .utf8) {
                    print("Search Response: \(responseString)")
                }
            })
            .decode(type: SearchStoriesResponse.self, decoder: decoder)
            .catch { error in
                if let customError = error as? CustomError, customError == .sessionExpired {
                    return Observable.error(CustomError.sessionExpired)
                }
                print("Search API Error: \(error)")
                return Observable.error(error)
            }
    }
}

 
