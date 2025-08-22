//
//  ForgotPasswordService.swift
//  Lumen
//
//  Created by Syed Mutahir Pirzada on 04/01/2025.
//

import Foundation
import RxSwift
import Alamofire


class ForgotPasswordService: BaseServiceClass, ForgotPasswordUseCaseProtocol {

    let client = RKAPIClient.shared

    func forgotPassword(email: String) -> Observable<ForgotPasswordModel> {
        
        let params: Parameters = [
            "email": email
        ]
        let req = buildURLRequest(path: Environment.resetPassword,
                                  httpMethod: .post,
                                  parameters: params)
        
        return client.requestData(req)
            .decode(type: ForgotPasswordModel.self, decoder: JSONDecoder())
    }
    
    func resendAuth(authyId: String) -> Observable<ForgotPasswordModel> {
        
        let params: Parameters = [
            "authy_id": authyId
        ]
        let req = buildURLRequest(path: Environment.resendAuthCode,
                                  httpMethod: .post,
                                  parameters: params)
        
        return client.requestData(req)
            .decode(type: ForgotPasswordModel.self, decoder: JSONDecoder())
    }
    
    func verifyCode(authyId: String, code: String) -> Observable<VerifyOTPModel> {
        let parameters: Parameters = [
            "authy_id": authyId,
            "token": code
        ]
        let req = buildURLRequest(path: Environment.verifyCode,
                                  httpMethod: .post,
                                  parameters: parameters)
        
        return client.requestData(req)
            .decode(type: VerifyOTPModel.self, decoder: JSONDecoder())
    }
}
