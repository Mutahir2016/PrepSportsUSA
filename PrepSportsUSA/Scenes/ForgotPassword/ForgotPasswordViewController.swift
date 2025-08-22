//
//  ForgotPasswordViewController.swift
//  Lumen
//
//  Created by Syed Mutahir Pirzada on 24/12/2024.
//

import UIKit
import MaterialComponents.MaterialTextControls_FilledTextFields
import MaterialComponents.MaterialTextControls_OutlinedTextFields
import RxSwift
import RxCocoa

class ForgotPasswordViewController: BaseViewController {
    @IBOutlet weak var enterTextLabel: UILabel!
    @IBOutlet var emailTextField: MDCOutlinedTextField!
    @IBOutlet weak var continueBtn: CustomButton!
    
    var viewModel: ForgotPasswordViewModel!
    var router: ForgotPasswordRouter!

    var continueAction: Observable<Void> {
        return self.continueBtn.rx.tap.asObservable()
    }
    

    override func callingInsideViewDidLoad() {
        setupUI()
        bindObservers()
    }

    override func setUp() {
        router = ForgotPasswordRouter()
    }

    private func setupUI() {
        enterTextLabel.font = UIFont.ibmRegular(size: 14.0)
        enterTextLabel.textColor = UIColor.outLineColor.withAlphaComponent(0.6)
        
        emailTextField.label.text = "Email"
        emailTextField.placeholder = "Email"
        emailTextField.setOutlineColor(UIColor.outLineColor, for: .normal)
        emailTextField.setNormalLabelColor(UIColor.outLineColor, for: .normal)
        
        continueBtn.setBackgroundColor(UIColor.appBtnBlueColor, for: .normal)
        continueBtn.setBackgroundColor(UIColor.appBtnDisabledColor, for: .disabled)
        continueBtn.setTitle("Continue", for: .normal)
        continueBtn.setTitle("Continue", for: .disabled)
        self.continueBtn.isEnabled = false
    }

    private func bindObservers() {
        disposeBag.insert {
            viewModel.emailFieldText
                .subscribe(onNext: { [weak self] text in
                    self?.emailTextField.text = text
                    print("emailFieldText in ViewModel updated to: \(text)")
                })
            
            // Two-way binding: TextField updates ViewModel
            emailTextField
                .rx
                .text
                .orEmpty
                .bind(to: viewModel.emailFieldText)
            
            // ViewModel updates TextField
            viewModel.emailFieldText
                .asDriver() // Ensure updates happen on main thread
                .drive(emailTextField.rx.text)
            
            // Observe isValidated to enable/disable the button
            viewModel.isValidated
                .observe(on: MainScheduler.instance)
                .subscribe(onNext: { [weak self] isValid in
                    self?.continueBtn.isEnabled = isValid
                })
            
            continueAction
                .subscribe(onNext: { [weak self] in
                    self?.viewModel.callForgotPasswordAPICall(self?.emailTextField.text ?? "")
                })
            
            viewModel
                .forgotPasswordMessage
                .bind(onNext: { [weak self] message in
                    if message != "" {
                        self?.showAlertAndNavigateBack(message: message)
                    }
                })
        }
    }
    
    func showAlertAndNavigateBack(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            // Navigate back
            self.navigationController?.popViewController(animated: true)
        }
        alert.addAction(okAction)
        
        // Present the alert
        self.present(alert, animated: true, completion: nil)
    }
}
