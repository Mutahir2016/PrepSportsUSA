//
//  SigninService.swift
//  Lumen
//
//  Created by Syed Mutahir Pirzada on 28/12/2024.
//

import Foundation
import RxSwift
import Alamofire

class SigninService: BaseServiceClass, SigninUseCaseProtocol {

    let client = RKAPIClient.shared

    func signIn(email: String, password: String) -> Observable<SignModel.LoginResponse> {
        
        let params: Parameters = [
            "email": email,
            "password": password
        ]
        let req = buildURLRequest(path: Environment.login,
                                  httpMethod: .post,
                                  parameters: params)
        
        return client.requestData(req)
            .decode(type: SignModel.LoginResponse.self, decoder: JSONDecoder())
    }
    
    func getUser(userId: Int) -> Observable<UserProfile> {
        
        let endPoint = String(format: Environment.userProfile, RKStorage.shared.getSignIn()?.user_id ?? 0)

        var request = buildURLRequest(path: endPoint,
                                  httpMethod: .get)
        
        request.setValue("Bearer \(RKStorage.shared.getSignIn()?.token ?? "")", forHTTPHeaderField: "Authorization")
        
        return client.requestData(request)
            .decode(type: UserProfile.self, decoder: JSONDecoder())
    }
}
