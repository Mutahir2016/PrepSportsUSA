//
//  NetworkServices.swift
//  Lumen
//
//  Created by Syed Mutahir Pirzada on 27/04/2025.
//

import RxSwift
import Alamofire

class NetworkServices: BaseServiceClass, NetworkUseCaseProtocol {
    
    let client = RKAPIClient.shared

    func getStoryWatcher(projectId: Int, fromDate: String, toDate: String) -> Observable<StoryHomeModel?> {
        let endPoint = String(format: Environment.getProjectWatcher, projectId)
        
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
            .map { data -> StoryHomeModel? in
                do {
                    return try decoder.decode(StoryHomeModel?.self, from: data)
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
    
    func getPageView(projectId: Int, pageNumber: Int, fromDate: String, toDate: String) -> Observable<PageViewModel?> {
        let endPoint = String(format: Environment.getProjectPageView, projectId)
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
    
    func getStoryOutlink(projectId: Int, pageNumber: Int, fromDate: String, toDate: String) -> Observable<NetworkOutLinkModel?> {
        let endPoint = String(format: Environment.getProjectOutlink, projectId)
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
            .map { data -> NetworkOutLinkModel? in
                do {
                    return try decoder.decode(NetworkOutLinkModel?.self, from: data)
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
    
    
    func getStoryGeography(projectId: Int, pageNumber: Int, fromDate: String, toDate: String) -> Observable<GeographyModel?> {
        let endPoint = String(format: Environment.getProjectGeography, projectId)
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
    
    func getStoryOrganizations(projectId: Int, pageNumber: Int, fromDate: String, toDate: String) -> Observable<TopOrganizationsModel?> {
        let endPoint = String(format: Environment.getProjectOrganization, projectId)
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
    
    func getProject(_ networkId: Int) -> Observable<NetworkModel?> {
        let endPoint = String(format: Environment.project, networkId)
        
        // Construct URL components with query parameters
        guard let components = URLComponents(string: endPoint) else {
            print("Error: Failed to construct URLComponents")
            return Observable.just(nil)
        }
        
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
        
        // Perform the network request
        return client.requestData(request)
            .do(onNext: { data in
                if let responseString = String(data: data, encoding: .utf8) {
                    print("Raw Response: \(responseString)")
                }
            })
            .map { data -> NetworkModel? in
                do {
                    return try decoder.decode(NetworkModel?.self, from: data)
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
    
    func getNetworks() -> Observable<NetworkModel?> {
        let endPoint = String(format: Environment.networks)
        
        // Construct URL components with query parameters
        guard let components = URLComponents(string: endPoint) else {
            print("Error: Failed to construct URLComponents")
            return Observable.just(nil)
        }
        
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
        
        // Perform the network request
        return client.requestData(request)
            .do(onNext: { data in
                if let responseString = String(data: data, encoding: .utf8) {
                    print("Raw Response: \(responseString)")
                }
            })
            .map { data -> NetworkModel? in
                do {
                    return try decoder.decode(NetworkModel?.self, from: data)
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
    
    func getStoryIndexing(projectId: Int, fromDate: String, toDate: String) -> Observable<IndexingModel?> {
        let endPoint = String(format: Environment.getIndexing, projectId)
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
    

    func getUser(userId: Int) -> Observable<UserProfile> {
        return Observable.create { observer in
            let endPoint = String(format: Environment.userProfile, RKStorage.shared.getSignIn()?.user_id ?? 0)
            var request = self.buildURLRequest(path: endPoint, httpMethod: .get)
            request.setValue("Bearer \(RKStorage.shared.getSignIn()?.token ?? "")", forHTTPHeaderField: "Authorization")

            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    observer.onError(RefreshTokenError.service(error: error))
                    return
                }

                guard let data = data, let httpResponse = response as? HTTPURLResponse else {
                    observer.onError(RefreshTokenError.service(error: NSError(domain: "", code: -1)))
                    return
                }

                if httpResponse.statusCode == 401 {
                    observer.onError(RefreshTokenError.service(error: NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Unauthorized"])))
                    return
                }

                do {
                    let decoded = try JSONDecoder().decode(UserProfile.self, from: data)
                    observer.onNext(decoded)
                    observer.onCompleted()
                } catch {
                    observer.onError(RefreshTokenError.service(error: error))
                }
            }

            task.resume()

            return Disposables.create {
                task.cancel()
            }
        }
    }
}
