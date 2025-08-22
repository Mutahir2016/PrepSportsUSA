//
//  ForgotPasswordUseCase.swift
//  Lumen
//
//  Created by Syed Mutahir Pirzada on 04/01/2025.
//

import Foundation
import RxSwift

protocol ForgotPasswordUseCaseProtocol {
    func forgotPassword(email: String) -> Observable<ForgotPasswordModel>
    func resendAuth(authyId: String) -> Observable<ForgotPasswordModel>
    func verifyCode(authyId: String, code: String) -> Observable<VerifyOTPModel>
}

class ForgotPasswordUseCase {
    let disposeBag: DisposeBag = DisposeBag()
    private var service: ForgotPasswordUseCaseProtocol
    
    init(service: ForgotPasswordService = ForgotPasswordService() ) {
        self.service = service
    }
    
    func forgotPassword(email: String) -> Observable<(ForgotPasswordModel)> {
        return service.forgotPassword(email: email)
    }
    
    func resendAuth(authyId: String) -> Observable<(ForgotPasswordModel)> {
        return service.resendAuth(authyId: authyId)
    }
    
    func verifyCode(authyId: String, code: String) -> Observable<(VerifyOTPModel)> {
        return service.verifyCode(authyId: authyId, code: code)
    }
}
