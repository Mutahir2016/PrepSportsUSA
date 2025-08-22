//
//  StoryHomeService.swift
//  Lumen
//
//  Created by Syed Mutahir Pirzada on 12/01/2025.
//

import Foundation
import RxSwift
import Alamofire

class StoryHomeService: BaseServiceClass, StoryHomeUseCaseProtocol {

    let client = RKAPIClient.shared

    func getStories(fromDate: String, toDate: String, page: Int, pageSize: Int, sortBy: String?) -> Observable<StoryHomeModel?> {
        
        let endPoint = String(format: Environment.getStoriesWatcher, RKStorage.shared.getSignIn()?.user_id ?? 0)

        var components = URLComponents(string: endPoint)!
        var queryItems = components.queryItems ?? []
        queryItems.append(URLQueryItem(name: "from_date", value: fromDate))
        queryItems.append(URLQueryItem(name: "to_date", value: toDate))
        queryItems.append(URLQueryItem(name: "page[size]", value: "\(pageSize)"))
        queryItems.append(URLQueryItem(name: "page[number]", value: "\(page)"))
        if sortBy != nil {
            queryItems.append(URLQueryItem(name: "sort", value: sortBy ?? ""))
        }
        
        components.queryItems = queryItems
        
        // Build the URL with proper percent encoding
        guard let encodedURL = components.url?.absoluteString,
              let decodedURL = encodedURL.removingPercentEncoding else {
            return Observable.just(nil) // Return a nil Observable if URL formation fails
        }
        
        var request = buildURLRequest(path: decodedURL, httpMethod: .get)
        
        request.setValue("Bearer \(RKStorage.shared.getSignIn()?.token ?? "")", forHTTPHeaderField: "Authorization")
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .appCustomStrategy
        
        return client.requestData(request)
            .do(onNext: { data in
                if let responseString = String(data: data, encoding: .utf8) {
                    print("Raw Response: \(responseString)")
                }
            })
            .decode(type: StoryHomeModel?.self, decoder: decoder)
            .catch { error in
                if let customError = error as? CustomError, customError == .sessionExpired {
                    return Observable.error(CustomError.sessionExpired)
                }
                return Observable.error(error)
            }
    }
}

