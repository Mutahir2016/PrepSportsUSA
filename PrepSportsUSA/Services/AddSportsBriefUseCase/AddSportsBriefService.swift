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
    
    // MARK: - Pre Pitch Media Upload
    func createPrePitchMediaLink(request: PrePitchMediaRequest) -> Observable<PrePitchMediaResponse> {
        return Observable.create { observer in
            let parameters = self.reqToDic(request: request)
            
            var urlRequest = self.buildURLRequest(
                path: Environment.prePitchMedia,
                httpMethod: .post,
                parameters: parameters,
                parameterEncoding: JSONEncoding.default
            )
            
            // Add authorization header
            if let token = RKStorage.shared.getSignIn()?.token {
                urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
            
            self.client.request(urlRequest) { (result: Result<PrePitchMediaResponse, AFError>) in
                switch result {
                case .success(let response):
                    observer.onNext(response)
                    observer.onCompleted()
                case .failure(let error):
                    observer.onError(error)
                }
            }
            
            return Disposables.create()
        }
    }
    
    // MARK: - Upload Image to Presigned URL
    func uploadImageToPresignedUrl(imageData: Data, presignedUrl: String, contentType: String) -> Observable<Bool> {
        return Observable.create { observer in
            guard let url = URL(string: presignedUrl) else {
                observer.onError(NSError(domain: "Invalid URL", code: 0, userInfo: nil))
                return Disposables.create()
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "PUT"
            request.setValue(contentType, forHTTPHeaderField: "Content-Type")
            request.httpBody = imageData
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    observer.onError(error)
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    let success = httpResponse.statusCode == 200
                    observer.onNext(success)
                    observer.onCompleted()
                } else {
                    observer.onNext(false)
                    observer.onCompleted()
                }
            }
            
            task.resume()
            
            return Disposables.create {
                task.cancel()
            }
        }
    }
    
    // MARK: - Create Pre Pitch
    func createPrePitch(request: PrePitchCreateRequest) -> Observable<PrePitchResponse> {
        return Observable.create { observer in
            let parameters = self.reqToDic(request: request)
            
            var urlRequest = self.buildURLRequest(
                path: Environment.prePitches,
                httpMethod: .post,
                parameters: parameters,
                parameterEncoding: JSONEncoding.default
            )
            
            // Add authorization header
            if let token = RKStorage.shared.getSignIn()?.token {
                urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
            
            self.client.request(urlRequest) { (result: Result<PrePitchResponse, AFError>) in
                switch result {
                case .success(let response):
                    observer.onNext(response)
                    observer.onCompleted()
                case .failure(let error):
                    observer.onError(error)
                }
            }
            
            return Disposables.create()
        }
    }
    
    // MARK: - Get Pre Pitch Types
    func getPrePitchTypes(page: Int, pageSize: Int) -> Observable<PrePitchTypesResponse> {
        return Observable.create { observer in
            let endpoint = "/pre_pitch_types"
            let parameters: [String: Any] = [
                "page[number]": page,
                "page[size]": pageSize
            ]
            
            var urlRequest = self.buildURLRequest(
                path: endpoint,
                httpMethod: .get,
                parameters: parameters,
                parameterEncoding: URLEncoding.default
            )
            
            // Add authorization header
            if let token = RKStorage.shared.getSignIn()?.token {
                urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
            
            self.client.request(urlRequest) { (result: Result<PrePitchTypesResponse, AFError>) in
                switch result {
                case .success(let response):
                    observer.onNext(response)
                    observer.onCompleted()
                case .failure(let error):
                    observer.onError(error)
                }
            }
            
            return Disposables.create()
        }
    }
    
    // MARK: - Get Selected Schools for Non-Admin Users
    func getSelectedSchools(page: Int = 1, pageSize: Int = 1) -> Observable<SchoolOrganizationResponse> {
        return Observable.create { observer in
            let endpoint = "/limpar/organizations/selected_schools"
            let parameters: [String: Any] = [
                "page[number]": page,
                "page[size]": pageSize
            ]
            
            var urlRequest = self.buildURLRequest(
                path: endpoint,
                httpMethod: .get,
                parameters: parameters,
                parameterEncoding: URLEncoding.default
            )
            
            // Add authorization header
            if let token = RKStorage.shared.getSignIn()?.token {
                urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
            
            self.client.request(urlRequest) { (result: Result<SchoolOrganizationResponse, AFError>) in
                switch result {
                case .success(let response):
                    observer.onNext(response)
                    observer.onCompleted()
                case .failure(let error):
                    observer.onError(error)
                }
            }
            
            return Disposables.create()
        }
    }
}
