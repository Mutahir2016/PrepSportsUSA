//
//  StoryHomeService.swift
//  Lumen
//
//  Created by Syed Mutahir Pirzada on 12/01/2025.
//

import Foundation
import RxSwift
import Alamofire

class ViewAllService: BaseServiceClass, ViewAllUseCaseProtocol {
   
    
    let client = RKAPIClient.shared
    
    func getStories(fromDate: String, toDate: String, page: Int, pageSize: Int) -> Observable<StoryHomeModel?> {
        
        let endPoint = String(format: Environment.getStoriesWatcher, RKStorage.shared.getSignIn()?.user_id ?? 0)
        
        var components = URLComponents(string: endPoint)!
        var queryItems = components.queryItems ?? []
        queryItems.append(URLQueryItem(name: "from_date", value: fromDate))
        queryItems.append(URLQueryItem(name: "to_date", value: toDate))
        queryItems.append(URLQueryItem(name: "page[size]", value: "\(pageSize)"))
        queryItems.append(URLQueryItem(name: "page[number]", value: "\(page)"))
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
    
    func getStoryGeography(storyId: String, pageNumber: Int, fromDate: String, toDate: String,isComingFromNetwork: Bool) -> Observable<GeographyModel?> {
        let baseURL = isComingFromNetwork ? Environment.getProjectGeographyy : Environment.getGeography
        let endPoint = String(format: baseURL, storyId)
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
            .decode(type: GeographyModel?.self, decoder: decoder)
    }
    
    func getStoryOutlink(storyId: String, pageNumber: Int, fromDate: String, toDate: String, isComingFromNetwork: Bool) -> Observable<OutlinkModel?> {
        let baseURL = isComingFromNetwork ? Environment.getProjectOutlinkk : Environment.getOutLinks
        let endPoint = String(format: baseURL, storyId)
        
        var components = URLComponents(string: endPoint)!
        var queryItems = components.queryItems ?? []
        queryItems.append(URLQueryItem(name: "from_date", value: fromDate))
        queryItems.append(URLQueryItem(name: "to_date", value: toDate))
        queryItems.append(URLQueryItem(name: "page[number]", value: "\(pageNumber)"))
        queryItems.append(URLQueryItem(name: "page[size]", value: "10"))

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
   
    func getStoryOrganizations(storyId: String, pageNumber: Int, fromDate: String, toDate: String, isComingFromNetwork: Bool) -> Observable<TopOrganizationsModel?> {
        
        let baseURL = isComingFromNetwork ? Environment.getProjectOrganizationn : Environment.getTopOrganizations
        let endPoint = String(format: baseURL, storyId)
        
        var components = URLComponents(string: endPoint)!
        var queryItems = components.queryItems ?? []
        queryItems.append(URLQueryItem(name: "from_date", value: fromDate))
        queryItems.append(URLQueryItem(name: "to_date", value: toDate))
        queryItems.append(URLQueryItem(name: "page[number]", value: "\(pageNumber)"))
        queryItems.append(URLQueryItem(name: "page[size]", value: "10"))

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
    
    func getStoryGeography(storyId: String, fromDate: String, toDate: String, isComingFromNetwork: Bool) -> Observable<GeographyModel?> {
        let baseURL = isComingFromNetwork ? Environment.getProjectGeographyy : Environment.getGeography
        let endPoint = String(format: baseURL, storyId)
        var components = URLComponents(string: endPoint)!
        var queryItems = components.queryItems ?? []
        queryItems.append(URLQueryItem(name: "page[number]", value: "0"))
        queryItems.append(URLQueryItem(name: "page[size]", value: "0"))
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
    
    func getStories(projectId: Int, fromDate: String, toDate: String, page: Int, pageSize: Int) -> Observable<StoryHomeModel?> {
        let endPoint = String(format: Environment.getProjectWatcher, projectId)
        
        var components = URLComponents(string: endPoint)!
        var queryItems = components.queryItems ?? []
        queryItems.append(URLQueryItem(name: "from_date", value: fromDate))
        queryItems.append(URLQueryItem(name: "to_date", value: toDate))
        queryItems.append(URLQueryItem(name: "page[size]", value: "\(pageSize)"))
        queryItems.append(URLQueryItem(name: "page[number]", value: "\(page)"))
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

