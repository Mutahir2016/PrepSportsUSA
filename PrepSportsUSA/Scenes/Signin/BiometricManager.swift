//
//  BiometricManager.swift
//  BiometricRx
//
//  Created by Syed Mutahir Pirzada on 25/10/2565 BE.
//

import LocalAuthentication
import RxSwift

protocol BiometricManagerLogic {
    func authenticationWithBiometrics() -> Observable<String>
}

class BiometricManager: BiometricManagerLogic {
    
    func authenticationWithBiometrics() -> Observable<String> {
        return Observable.create { observer in
            let context = LAContext()
            context.localizedFallbackTitle = "Use Passcode"
            
            var error: NSError?
            let reason = "Login to Newsmaker"
            
            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                // Check biometric type (Face ID or Touch ID)
                let biometricType = context.biometryType == .faceID ? "Face ID" : "Touch ID"
                print("Biometric Type Available: \(biometricType)")
                
                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authError in
                    if success {
                        observer.onNext("")
                    } else {
                        if let error = authError {
                            observer.onNext(UIViewController.evaluateAuthenticationPolicyMessageForLA(errorCode: error._code))
                        } else {
                            observer.onNext("Authentication failed")
                        }
                    }
                }
            } else {
                if let error = error {
                    observer.onNext(UIViewController.evaluateAuthenticationPolicyMessageForLA(errorCode: error._code))
                } else {
                    observer.onNext("Biometric authentication not available")
                }
            }
            
            return Disposables.create()
        }
    }
}
