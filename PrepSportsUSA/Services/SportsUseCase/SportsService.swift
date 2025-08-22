//
//  SportsService.swift
//  PrepSportsUSA
//
//  Created by PrepSportsUSA on 23/08/2025.
//

import Foundation
import RxSwift
import Alamofire

class SportsService: BaseServiceClass, SportsUseCaseProtocol {

    let client = RKAPIClient.shared

    func getPrePitches(pageSize: Int, pageNumber: Int) -> Observable<PrePitchesModel?> {
        let endPoint = Environment.prePitches
        
        // Build query string manually to ensure proper encoding
        let queryString = "page[size]=\(pageSize)&page[number]=\(pageNumber)"
        let fullPath = "\(endPoint)?\(queryString)"
        
        print("Pre-Pitches API Path: \(fullPath)")
        print("Pre-Pitches Full URL: \(Environment.baseURL)\(fullPath)")
        
        // Build the URL request using the base service method
        var request = buildURLRequest(path: fullPath, httpMethod: .get)
        if let token = RKStorage.shared.getSignIn()?.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            print("Authorization token: Bearer \(token)")
        } else {
            print("Warning: Missing authorization token for pre-pitches")
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
                    print("Pre-Pitches Raw Response: \(responseString)")
                }
            })
            .map { data -> PrePitchesModel? in
                do {
                    return try decoder.decode(PrePitchesModel?.self, from: data)
                } catch let DecodingError.keyNotFound(key, context) {
                    print("Pre-Pitches Decoding Error: Missing key '\(key)' - \(context.debugDescription)")
                    print("Coding Path: \(context.codingPath)")
                } catch let DecodingError.valueNotFound(value, context) {
                    print("Pre-Pitches Decoding Error: Missing value for '\(value)' - \(context.debugDescription)")
                    print("Coding Path: \(context.codingPath)")
                } catch let DecodingError.typeMismatch(type, context) {
                    print("Pre-Pitches Decoding Error: Type mismatch for '\(type)' - \(context.debugDescription)")
                    print("Coding Path: \(context.codingPath)")
                } catch let DecodingError.dataCorrupted(context) {
                    print("Pre-Pitches Decoding Error: Data corrupted - \(context.debugDescription)")
                } catch {
                    print("Pre-Pitches Decoding Error: \(error)")
                }
                return nil
            }
            .catch { error in
                print("Pre-Pitches Network Error: \(error.localizedDescription)")
                return Observable.just(nil)
            }
    }
}
