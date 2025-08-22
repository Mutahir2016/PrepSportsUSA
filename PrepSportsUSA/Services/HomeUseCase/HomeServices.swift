//
//  HomeServices.swift
//  Lumen
//
//  Created by Syed Mutahir Pirzada on 28/01/2025.
//

import RxSwift
import Alamofire

class HomeService: BaseServiceClass, HomeUseCaseProtocol {
    
    let client = RKAPIClient.shared

    func getStoryWatcher(userId: Int, fromDate: String, toDate: String) -> Observable<HomeStoryModel?> {
        let endPoint = String(format: Environment.getStoriesWatcher, userId)
        
        // Construct URL components with query parameters
        guard var components = URLComponents(string: endPoint) else {
            print("Error: Failed to construct URLComponents")
            return Observable.just(nil)
        }
        components.queryItems = [
            URLQueryItem(name: "from_date", value: fromDate),
            URLQueryItem(name: "to_date", value: toDate)
        ]
        
        // Ensure the URL is valid
        guard let url = components.url else {
            print("Error: Failed to create URL from components")
            return Observable.just(nil)
        }
        
        // Build the URL request
        var request = buildURLRequest(path: url.absoluteString, httpMethod: .get)
        if let token = RKStorage.shared.getSignIn()?.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            print("Warning: Missing authorization token")
        }
        
        // Configure the JSON decoder
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .appCustomStrategy
        
        // Perform the network request
        return client.requestData(request)
            .do(onNext: { data in
                if let responseString = String(data: data, encoding: .utf8) {
                    print("Raw Response: \(responseString)")
                }
            })
            .map { data -> HomeStoryModel? in
                do {
                    return try decoder.decode(HomeStoryModel?.self, from: data)
                } catch let DecodingError.keyNotFound(key, context) {
                    print("Decoding Error: Missing key '\(key)' - \(context.debugDescription)")
                    print("Coding Path: \(context.codingPath)")
                } catch let DecodingError.valueNotFound(value, context) {
                    print("Decoding Error: Missing value for '\(value)' - \(context.debugDescription)")
                    print("Coding Path: \(context.codingPath)")
                } catch let DecodingError.typeMismatch(type, context) {
                    print("Decoding Error: Type mismatch for '\(type)' - \(context.debugDescription)")
                    print("Coding Path: \(context.codingPath)")
                } catch let DecodingError.dataCorrupted(context) {
                    print("Decoding Error: Data corrupted - \(context.debugDescription)")
                } catch {
                    print("Decoding Error: \(error)")
                }
                return nil
            }
            .catch { error in
                print("Network Error: \(error.localizedDescription)")
                return Observable.just(nil)
            }
    }

    
    func getPageView(userId: Int, pageNumber: Int, fromDate: String, toDate: String) -> Observable<PageViewModel?> {
        let endPoint = String(format: Environment.getStoryWatcherPageView, userId)
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
    }
    
    func getStoryGeography(userId: Int, pageNumber: Int, fromDate: String, toDate: String) -> Observable<GeographyModel?> {
        let endPoint = String(format: Environment.getStoryWatcherGeography, userId)
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
    
    func getStoryOrganizations(userId: Int, pageNumber: Int, fromDate: String, toDate: String) -> Observable<TopOrganizationsModel?> {
        let endPoint = String(format: Environment.getStoryWatcherOrganization, userId)
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
            .map { data -> TopOrganizationsModel? in
                do {
                    return try decoder.decode(TopOrganizationsModel?.self, from: data)
                } catch let DecodingError.keyNotFound(key, context) {
                    print("Decoding Error: Missing key '\(key)' - \(context.debugDescription)")
                    print("Coding Path: \(context.codingPath)")
                } catch let DecodingError.valueNotFound(value, context) {
                    print("Decoding Error: Missing value for '\(value)' - \(context.debugDescription)")
                    print("Coding Path: \(context.codingPath)")
                } catch let DecodingError.typeMismatch(type, context) {
                    print("Decoding Error: Type mismatch for '\(type)' - \(context.debugDescription)")
                    print("Coding Path: \(context.codingPath)")
                } catch let DecodingError.dataCorrupted(context) {
                    print("Decoding Error: Data corrupted - \(context.debugDescription)")
                } catch {
                    print("Decoding Error: \(error)")
                }
                return nil
            }
            .catch { error in
                print("Network Error: \(error.localizedDescription)")
                return Observable.just(nil)
            }
    }
    
    func getStoryOutlink(userId: Int, pageNumber: Int, fromDate: String, toDate: String) -> Observable<HomeOutLinkModel?> {
        let endPoint = String(format: Environment.getStoryWatcherOutlink, userId)
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
            .map { data -> HomeOutLinkModel? in
                do {
                    return try decoder.decode(HomeOutLinkModel?.self, from: data)
                } catch let DecodingError.keyNotFound(key, context) {
                    print("Decoding Error: Missing key '\(key)' - \(context.debugDescription)")
                    print("Coding Path: \(context.codingPath)")
                } catch let DecodingError.valueNotFound(value, context) {
                    print("Decoding Error: Missing value for '\(value)' - \(context.debugDescription)")
                    print("Coding Path: \(context.codingPath)")
                } catch let DecodingError.typeMismatch(type, context) {
                    print("Decoding Error: Type mismatch for '\(type)' - \(context.debugDescription)")
                    print("Coding Path: \(context.codingPath)")
                } catch let DecodingError.dataCorrupted(context) {
                    print("Decoding Error: Data corrupted - \(context.debugDescription)")
                } catch {
                    print("Decoding Error: \(error)")
                }
                return nil
            }
            .catch { error in
                print("Network Error: \(error.localizedDescription)")
                return Observable.just(nil)
            }
    }
}
