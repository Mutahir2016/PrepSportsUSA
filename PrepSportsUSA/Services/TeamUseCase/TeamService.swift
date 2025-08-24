//
//  TeamService.swift
//  PrepSportsUSA
//
//  Created by PrepSportsUSA on 25/08/2025.
//

import Foundation
import RxSwift
import Alamofire

class TeamService: BaseServiceClass, TeamUseCaseProtocol {
    
    let client = RKAPIClient.shared
    
    func getTeams(organizationId: String, sex: String, pageSize: Int, pageNumber: Int) -> Observable<TeamResponse?> {
        let endPoint = "/limpar/teams"
        
        // Build query string manually to ensure proper encoding
        var queryParams = [
            "organization_id=\(organizationId)",
            "sex=\(sex)",
            "page[size]=\(pageSize)",
            "page[number]=\(pageNumber)"
        ]
        
        let queryString = queryParams.joined(separator: "&")
        let fullPath = "\(endPoint)?\(queryString)"
        
        print("Teams API Path: \(fullPath)")
        print("Teams Full URL: \(Environment.baseURL)\(fullPath)")
        
        // Build the URL request using the base service method
        var request = buildURLRequest(path: fullPath, httpMethod: .get)
        if let token = RKStorage.shared.getSignIn()?.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            print("Authorization token: Bearer \(token)")
        } else {
            print("Warning: Missing authorization token for teams")
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
                    print("Teams Raw Response: \(responseString)")
                }
            })
            .decode(type: TeamResponse?.self, decoder: decoder)
            .catch { error in
                if let customError = error as? CustomError, customError == .sessionExpired {
                    return Observable.error(CustomError.sessionExpired)
                }
                print("Teams Network Error: \(error.localizedDescription)")
                return Observable.error(error)
            }
    }
}
