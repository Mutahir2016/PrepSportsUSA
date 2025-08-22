//
//  SigninUseCase.swift
//  Lumen
//
//  Created by Syed Mutahir Pirzada on 28/12/2024.
//

import Foundation
import RxSwift

protocol SigninUseCaseProtocol {
    func signIn(email: String, password: String) -> Observable<SignModel.LoginResponse>
    func getUser(userId: Int) -> Observable<UserProfile>
}

class SigninUseCase {
    let disposeBag: DisposeBag = DisposeBag()
    private var service: SigninUseCaseProtocol
    
    init(service: SigninService = SigninService() ) {
        self.service = service
    }
    
    func getSignin(email: String, password: String) -> Observable<(SignModel.LoginResponse)> {
        return service.signIn(email: email, password: password)
    }
    
    func getUserProfile(userId: Int) -> Observable<UserProfile> {
        return service.getUser(userId: userId)
    }
}
