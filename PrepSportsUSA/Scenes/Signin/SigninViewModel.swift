//
//  SigninViewModel.swift
//  Lumen
//
//  Created by Syed Mutahir Pirzada on 23/12/2024.
//

import Foundation
import RxSwift
import RxCocoa
import AuthenticationServices


final class SigninViewModel: BaseViewModel {
    var isValidated = BehaviorRelay<Bool>(value: false) // ✅ Stores last validation state

    var emailFieldText = BehaviorRelay<String>(value: "")
    var passwordFieldText = BehaviorRelay<String>(value: "")
    var signInUsecase: SigninUseCase?
    var router: SigninRouter!
    let isLoadingRelay = BehaviorRelay<Bool>(value: false)
    var errorMessage = BehaviorRelay(value: "")
    var biometricRelay = PublishRelay<Void>()
    
    init(useCase: SigninUseCase = SigninUseCase(), router: SigninRouter) {
        
        super.init()
        signInUsecase = useCase
        self.router = router
        // Combine email and password validation
        Observable
            .combineLatest(emailFieldText, passwordFieldText)
            .map { [weak self] email, password in
                return self?.isValidEmail(email) == true && self?.isValidPassword(password) == true
            }
            .bind(to: isValidated)
            .disposed(by: disposeBag)
    }
    
    func useStoredCredentials() {
        let email = UserDefaults.standard.value(forKey: UserCredentialKeys.email.rawValue) as? String
        let password = UserDefaults.standard.value(forKey: UserCredentialKeys.password.rawValue) as? String
        callSignInAPICall(email: email ?? "", password: password ?? "")
    }
    
    func callSignInAPICall(email: String, password: String) {
        guard let useCase = signInUsecase else { return }
        isLoadingRelay.accept(true)
        
        useCase
            .getSignin(email: email, password: password)
            .subscribe(onNext: { [weak self] response in
                guard let self = self else { return }
                UserDefaults.standard.set(emailFieldText.value, forKey: UserCredentialKeys.email.rawValue)
                UserDefaults.standard.set(String(describing: password), forKey: UserCredentialKeys.password.rawValue)
                
                if checkIfTokenExists(response) {
                    RKStorage.shared.saveSignIn(tokenModel: response)
                    self.saveCredentialToKeychain(email: email, password: password)

                    self.getUserProfile()
                } else if checkIfMetaExists(response) {
                    self.router.routeToAuthVerification(email: email, and: response)
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
    
    func getUserProfile() {
        guard let useCase = signInUsecase else { return }
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
                    self.router.routeToNetwork()
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
    
    func checkIfTokenExists(_ response: SignModel.LoginResponse) -> Bool {
        if let token = response.token, !token.isEmpty {
            return true
        }
        return false
    }
    
    func shouldShowBiometricPopUp() -> Bool {
        let biometricEnabled = UserDefaults.standard.bool(forKey: RKStorageAccount.biometricEnabled.rawValue)
        let currentEmail = emailFieldText.value
        let storedEmail = UserDefaults.standard.string(forKey: RKStorageAccount.biometricEnabledUser.rawValue)
        
        // Show biometric prompt only if biometric is NOT enabled for current user
        return biometricEnabled && storedEmail == currentEmail
    }
    
    func checkBiometricConfig() -> Bool {
        if UserDefaults.standard.bool(forKey: RKStorageAccount.biometricEnabled.rawValue) == true {
            return true
        }
        return false
    }
    
    func checkIfMetaExists(_ response: SignModel.LoginResponse) -> Bool {
        if response.meta?.two_factor_required == true && response.meta?.authy_id != nil && response.meta?.code_send == true {
            return true
        }
        return false
    }
    
    private func saveCredentialToKeychain(email: String, password: String) {
        let serviceIdentifier = ASCredentialServiceIdentifier(identifier: "yourapp.com", type: .domain) // Replace with your app domain

        let credentialIdentity = ASPasswordCredentialIdentity(
            serviceIdentifier: serviceIdentifier,
            user: email,
            recordIdentifier: nil
        )

        let store = ASCredentialIdentityStore.shared
        store.saveCredentialIdentities([credentialIdentity]) { success, error in
            if success {
                print("✅ Credentials saved to iCloud Keychain.")
            } else {
                print("❌ Failed to save credentials: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }

}


