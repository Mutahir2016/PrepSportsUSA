//
//  ForgotPasswordViewModel.swift
//  Lumen
//
//  Created by Syed Mutahir Pirzada on 24/12/2024.
//

import Foundation
import RxSwift
import RxCocoa

final class ForgotPasswordViewModel: BaseViewModel {
    var isValidated = PublishSubject<Bool>() // Emits when both email and password are valid
    var emailFieldText = BehaviorRelay<String>(value: "")
    var forgotPasswordUsecase: ForgotPasswordUseCase?
    var forgotPasswordMessage = BehaviorRelay(value: "")
    
    init(email: String?, useCase: ForgotPasswordUseCase = ForgotPasswordUseCase()) {
        super.init() // Call the superclass initializer first
        emailFieldText.accept(email ?? "")
        self.forgotPasswordUsecase = useCase
        setupValidation()
    }

    private func setupValidation() {
        emailFieldText
            .map { [weak self] email in
                self?.isValidEmail(email) ?? false
            }
            .bind(to: isValidated)
            .disposed(by: disposeBag)
    }
    
    func callForgotPasswordAPICall(_ email: String) {
        guard let useCase = forgotPasswordUsecase else { return }
        useCase
            .forgotPassword(email: emailFieldText.value)
            .subscribe(
                onNext: { [weak self] response in
                    guard let self = self else { return }
                    if let message = response.meta?.message, !message.isEmpty {
                        forgotPasswordMessage.accept(message)
                    }
                },
                onError: { [weak self] error in
                    guard let self = self else { return }
                    // Handle the error
                    print("Forgot Password API Error: \(error.localizedDescription)")
                    // Optionally show the error to the user or update UI
                    self.forgotPasswordMessage.accept("An error occurred. Please try again.")
                }
            )
            .disposed(by: disposeBag)
    }

}
