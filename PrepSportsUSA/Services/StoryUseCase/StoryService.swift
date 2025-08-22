//
//  StoryService.swift
//  Lumen
//
//  Created by Syed Mutahir Pirzada on 18/01/2025.
//

import RxSwift
import Alamofire

class StoryService: BaseServiceClass, StoryUseCaseProtocol {
    
    let client = RKAPIClient.shared

    func getStoryGeography(storyId: String, pageNumber: Int, fromDate: String, toDate: String) -> Observable<GeographyModel?> {
        let endPoint = String(format: Environment.getGeography, storyId)
        var components = URLComponents(string: endPoint)!
        var queryItems = components.queryItems ?? []
        queryItems.append(URLQueryItem(name: "page[number]", value: "\(pageNumber)"))
        queryItems.append(URLQueryItem(name: "page[size]", value: "5"))
        queryItems.append(URLQueryItem(name: "from_date", value: fromDate))
        queryItems.append(URLQueryItem(name: "to_date", value: toDate))
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
            .decode(type: GeographyModel?.self, decoder: decoder)
    }
    
    func getStoryIndexing(storyId: String, fromDate: String, toDate: String) -> Observable<IndexingModel?> {
        let endPoint = String(format: Environment.getIndexing, storyId)
        var components = URLComponents(string: endPoint)!
        var queryItems = components.queryItems ?? []
        queryItems.append(URLQueryItem(name: "from_date", value: fromDate))
        queryItems.append(URLQueryItem(name: "to_date", value: toDate))
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
            .decode(type: IndexingModel?.self, decoder: decoder)
            .catch { error in
                if let customError = error as? CustomError, customError == .sessionExpired {
                    return Observable.error(CustomError.sessionExpired)
                }
                return Observable.error(error)
            }
    }
    
    func getStoryOutlink(storyId: String, pageNumber: Int, fromDate: String, toDate: String) -> Observable<OutlinkModel?> {
        let endPoint = String(format: Environment.getOutLinks, storyId)
        var components = URLComponents(string: endPoint)!
        var queryItems = components.queryItems ?? []
        queryItems.append(URLQueryItem(name: "from_date", value: fromDate))
        queryItems.append(URLQueryItem(name: "to_date", value: toDate))
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
            .decode(type: OutlinkModel?.self, decoder: decoder)
            .catch { error in
                if let customError = error as? CustomError, customError == .sessionExpired {
                    return Observable.error(CustomError.sessionExpired)
                }
                return Observable.error(error)
            }
    }
    
    func getStoryOrganizations(storyId: String, pageNumber: Int, fromDate: String, toDate: String) -> Observable<TopOrganizationsModel?> {
        let endPoint = String(format: Environment.getTopOrganizations, storyId)
        var components = URLComponents(string: endPoint)!
        var queryItems = components.queryItems ?? []
        queryItems.append(URLQueryItem(name: "from_date", value: fromDate))
        queryItems.append(URLQueryItem(name: "to_date", value: toDate))
        queryItems.append(URLQueryItem(name: "page[size]", value: "5"))
        queryItems.append(URLQueryItem(name: "page[number]", value: "\(pageNumber)"))
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
            .decode(type: TopOrganizationsModel?.self, decoder: decoder)
            .catch { error in
                if let customError = error as? CustomError, customError == .sessionExpired {
                    return Observable.error(CustomError.sessionExpired)
                }
                return Observable.error(error)
            }
    }
    
    func getStory(storyId: String, fromDate: String, toDate: String) -> Observable<StoryModel?> {
        let endPoint = String(format: Environment.getStory, storyId)
        var components = URLComponents(string: endPoint)!
        var queryItems = components.queryItems ?? []
        queryItems.append(URLQueryItem(name: "from_date", value: fromDate))
        queryItems.append(URLQueryItem(name: "to_date", value: toDate))
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
            .decode(type: StoryModel?.self, decoder: decoder)
            .catch { error in
                if let customError = error as? CustomError, customError == .sessionExpired {
                    return Observable.error(CustomError.sessionExpired)
                }
                return Observable.error(error)
            }
    }
    
    func getPageView(storyId: String, pageNumber: Int, fromDate: String, toDate: String) -> Observable<PageViewModel?> {
        let endPoint = String(format: Environment.getPageView, storyId)
        var components = URLComponents(string: endPoint)!
        var queryItems = components.queryItems ?? []
        queryItems.append(URLQueryItem(name: "page[number]", value: "\(pageNumber)"))
        queryItems.append(URLQueryItem(name: "page[size]", value: "10"))
        queryItems.append(URLQueryItem(name: "from_date", value: fromDate))
        queryItems.append(URLQueryItem(name: "to_date", value: toDate))
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
            .decode(type: PageViewModel?.self, decoder: decoder)
            .catch { error in
                if let customError = error as? CustomError, customError == .sessionExpired {
                    return Observable.error(CustomError.sessionExpired)
                }
                return Observable.error(error)
            }
    }
}
