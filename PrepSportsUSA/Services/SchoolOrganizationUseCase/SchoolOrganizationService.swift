//
//  SchoolOrganizationService.swift
//  PrepSportsUSA
//
//  Created by PrepSportsUSA on 25/08/2025.
//

import Foundation
import RxSwift
import Alamofire

class SchoolOrganizationService: BaseServiceClass, SchoolOrganizationUseCaseProtocol {
    
    let client = RKAPIClient.shared
    
    func getSchoolOrganizations(pageSize: Int, pageNumber: Int) -> Observable<SchoolOrganizationResponse?> {
        let endPoint = "/limpar/organizations/schools"
        
        // Build query string manually to ensure proper encoding
        let queryString = "page[size]=\(pageSize)&page[number]=\(pageNumber)"
        let fullPath = "\(endPoint)?\(queryString)"
        
        print("School Organizations API Path: \(fullPath)")
        print("School Organizations Full URL: \(Environment.baseURL)\(fullPath)")
        
        // Build the URL request using the base service method
        var request = buildURLRequest(path: fullPath, httpMethod: .get)
        if let token = RKStorage.shared.getSignIn()?.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            print("Authorization token: Bearer \(token)")
        } else {
            print("Warning: Missing authorization token for school organizations")
        }
        
        // Debug: Print all request headers
        print("Request headers: \(request.allHTTPHeaderFields ?? [:])")
        print("Request method: \(request.httpMethod ?? "Unknown")")
        print("Full request URL: \(request.url?.absoluteString ?? "No URL")")
        
        // Configure the JSON decoder
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .appCustomStrategy
        
        // Perform the network request
        return client.requestData(request)
            .do(onNext: { data in
                if let responseString = String(data: data, encoding: .utf8) {
                    print("School Organizations Raw Response: \(responseString)")
                }
            })
            .decode(type: SchoolOrganizationResponse?.self, decoder: decoder)
            .catch { error in
                if let customError = error as? CustomError, customError == .sessionExpired {
                    return Observable.error(CustomError.sessionExpired)
                }
                print("School Organizations Network Error: \(error.localizedDescription)")
                return Observable.error(error)
            }
    }
}
