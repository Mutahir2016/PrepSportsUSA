//
//  AuthVerificationViewModel.swift
//  Lumen
//
//  Created by Syed Mutahir Pirzada on 25/12/2024.
//

import Foundation
import RxSwift
import RxCocoa

final class AuthVerificationViewModel: BaseViewModel {
    var emailFieldText = BehaviorRelay<String>(value: "")
    var forgotPasswordUsecase: ForgotPasswordUseCase?
    var signInData: signInData?
    var forgotPasswordMessage = BehaviorRelay(value: "")
    let isLoadingRelay = BehaviorRelay<Bool>(value: false)
    var biometricRelay = PublishRelay<Void>()
    var router: AuthVerificationRouter!
    var errorMessage = BehaviorRelay(value: "")

    override init() {
        super.init()
    }
    
    init(email: String?, signInData: signInData, useCase: ForgotPasswordUseCase = ForgotPasswordUseCase(), router: AuthVerificationRouter) {
        super.init() // Call the superclass initializer first
        emailFieldText.accept(email ?? "")
        self.signInData = signInData
        self.router = router
        self.forgotPasswordUsecase = useCase
    }

    func validatePinCode(_ pinCode: String) -> Bool {
        if pinCode == "" {
            return false
        }
        return true
    }
    
    func resendAuth() {
        guard let useCase = forgotPasswordUsecase else { return }
        useCase
            .resendAuth(authyId: signInData?.meta?.authy_id ?? "")
            .subscribe(
                onNext: { [weak self] response in
                    guard let self = self else { return }
                    if let message = response.meta?.message, !message.isEmpty {
//                        forgotPasswordMessage.accept(message)
                    }
                },
                onError: { [weak self] error in
                    guard let self = self else { return }
                    // Handle the error
                    print("Resend Auth API Error: \(error.localizedDescription)")
                    // Optionally show the error to the user or update UI
                    self.forgotPasswordMessage.accept("Error sending code")
                }
            )
            .disposed(by: disposeBag)
    }
    
    func verifyPinCode(_ pinCode: String) {
        guard let useCase = forgotPasswordUsecase else { return }
        useCase
            .verifyCode(authyId: signInData?.meta?.authy_id ?? "", code: pinCode)
            .subscribe(
                onNext: { [weak self] response in
                    guard let self = self else { return }
                    if let token = response.token {
                        
                        let loginData = SignModel.LoginResponse(
                            meta: SignModel.MetaData(
                                two_factor_required: false,
                                code_send: false,
                                authy_id: nil,
                                user_id: nil
                            ),
                            token: token,
                            user_id: response.user_id ?? 0,
                            error: nil
                        )
                        
                        RKStorage.shared.saveSignIn(tokenModel: loginData)
                        self.getUserProfile()
                    }
                },
                onError: { [weak self] error in
                    guard let self = self else { return }
                    // Handle the error
                    print("Resend Auth API Error: \(error.localizedDescription)")
                    // Optionally show the error to the user or update UI
                    self.forgotPasswordMessage.accept("An error occurred. Please try again.")
                }
            )
            .disposed(by: disposeBag)
    }
    
    func getUserProfile() {
        let useCase: SigninUseCase = SigninUseCase()
        isLoadingRelay.accept(true)
        
        let userId = RKStorage.shared.getSignIn()?.user_id ?? 0
        useCase
            .getUserProfile(userId: userId)
            .subscribe(onNext: { [weak self] response in
                guard let self = self else { return }
                RKStorage.shared.saveUserProfile(userProfile: response)
                if !shouldShowBiometricPopUp() {
                    biometricRelay.accept(())
                } else {
                    self.router.routeToStories()
                }
                isLoadingRelay.accept(false)
            },
                       onError: { [weak self] error in
                guard let self = self else { return }
                isLoadingRelay.accept(false)
                errorMessage.accept(error.localizedDescription)
                // Handle the error
            }).disposed(by: disposeBag)
    }
    
    func shouldShowBiometricPopUp() -> Bool {
        return UserDefaults.standard.bool(forKey: RKStorageAccount.biometricEnabled.rawValue)
    }
}

