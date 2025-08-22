//
//  ViewController.swift
//  Lumen
//
//  Created by Syed Mutahir Pirzada on 17/12/2024.
//

import UIKit
import RxSwift
import RxCocoa

import MaterialComponents.MaterialTextControls_FilledTextFields
import MaterialComponents.MaterialTextControls_OutlinedTextFields

class SigninViewController: BaseViewController {

    @IBOutlet var signInTitleLabel: UILabel!
    @IBOutlet var emailTextField: MDCOutlinedTextField!
    @IBOutlet var passwordTextField: MDCOutlinedTextField!
    @IBOutlet var forgotPasswordLabel: UILabel!
    @IBOutlet var errorMsgLabel: UILabel!
    @IBOutlet weak var continueBtn: CustomButton!
    @IBOutlet weak var forgotBtn: UIButton!
    @IBOutlet weak var activityIndicator: LoadingIndicatorView!
    @IBOutlet weak var faceIdBtn: UIButton!
    private let biometricManager = BiometricManager()

    var viewModel: SigninViewModel!
    var router: SigninRouter!
    var continueAction: Observable<Void> {
        return self.continueBtn.rx.tap.asObservable()
    }
    
    var forgotAction: Observable<Void> {
        return self.forgotBtn.rx.tap.asObservable()
    }
    
    var faceIdAction: Observable<Void> {
        return self.faceIdBtn.rx.tap.asObservable()
    }
    
    override func callingInsideViewDidLoad() {
        // Do any additional setup after loading the view.
        viewModel = SigninViewModel(router: router)
        setupUI()
        
        bindObservers()
    }
    
    override func setUp() {
        router = SigninRouter(self)
    }
    
    private func setupUI() {
        if let emailText = UserDefaults.standard.value(forKey: UserCredentialKeys.email.rawValue) as? String {
            emailTextField.text = emailText
        }

        emailTextField.label.text = "Email"
        emailTextField.placeholder = "Email"
        emailTextField.returnKeyType = .next
        emailTextField.delegate = self
        emailTextField.setOutlineColor(UIColor.outLineColor, for: .normal)
        emailTextField.setNormalLabelColor(UIColor.outLineColor, for: .normal)

        passwordTextField.label.text = "Password"
        passwordTextField.placeholder = "Password"
        passwordTextField.isSecureTextEntry = true
        passwordTextField.returnKeyType = .done
        passwordTextField.delegate = self
        passwordTextField.setOutlineColor(UIColor.outLineColor, for: .normal)
        passwordTextField.setNormalLabelColor(UIColor.outLineColor, for: .normal)

        emailTextField.inputAccessoryView = nil
        emailTextField.textContentType = .username  // Instead of .none
        emailTextField.autocapitalizationType = .none

        emailTextField.autocorrectionType = .no
        emailTextField.spellCheckingType = .no
        emailTextField.smartDashesType = .no
        emailTextField.smartInsertDeleteType = .no
        emailTextField.smartQuotesType = .no

        passwordTextField.textContentType = .password
        passwordTextField.autocorrectionType = .no
        passwordTextField.spellCheckingType = .no
        passwordTextField.inputAccessoryView = nil

        // ✅ Add eye icon to toggle password visibility
        let eyeButton = UIButton(type: .custom)
        eyeButton.setImage(UIImage(systemName: "eye.fill"), for: .normal)
        eyeButton.setImage(UIImage(systemName: "eye.slash.fill"), for: .selected)
        eyeButton.tintColor = .gray
        eyeButton.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        eyeButton.addTarget(self, action: #selector(togglePasswordVisibility(_:)), for: .touchUpInside)

        let container = UIView(frame: CGRect(x: 0, y: 0, width: 36, height: 24))
        container.addSubview(eyeButton)
        eyeButton.center = container.center

        passwordTextField.trailingView = container
        passwordTextField.trailingViewMode = .always

        forgotPasswordLabel.textColor = UIColor.appBlueColor
        continueBtn.setBackgroundColor(UIColor.appBtnBlueColor, for: .normal)
        continueBtn.setBackgroundColor(UIColor.appBtnDisabledColor, for: .disabled)

        continueBtn.setTitle("Login", for: .normal)
        continueBtn.setTitle("Login", for: .disabled)

        errorMsgLabel.textColor = UIColor.appErrorRedColor
        errorMsgLabel.font = UIFont.ibmRegular(size: 14.0)
        errorMsgLabel.isHidden = true
        self.continueBtn.isEnabled = false
    }
    
    @objc private func togglePasswordVisibility(_ sender: UIButton) {
        if passwordTextField.text?.isEmpty ?? true { return }
        sender.isSelected.toggle()
        passwordTextField.isSecureTextEntry.toggle()
    }
    
    private func bindObservers() {
        disposeBag.insert {
            
            // Bind email and password inputs to ViewModel
            emailTextField
                .rx
                .text
                .orEmpty
                .bind(to: viewModel.emailFieldText)
            
            passwordTextField
                .rx
                .text
                .orEmpty
                .bind(to: viewModel.passwordFieldText)
            
            // Observe the isValidated property to enable/disable the button
            viewModel.isValidated
                .observe(on: MainScheduler.instance)
                .subscribe(onNext: { [weak self] isValid in
                    print("Are credentials valid: \(isValid)")
                    self?.continueBtn.isEnabled = isValid
                    if isValid {
                        self?.continueBtn.setTitle("Login", for: .normal)
                    } else {
                        self?.continueBtn.setTitle("Login", for: .disabled)
                    }
                })
            
            forgotAction
                .subscribe(onNext: {
                    self.router?.routeToForgetPassword(self.emailTextField.text ?? "")
                })
            
            continueAction
                .subscribe(onNext: { [weak self] in
                    self?.triggerContinueAction()
                })
            
            // ✅ Ensure "Return" key only triggers sign-in when credentials are valid
            passwordTextField.rx.controlEvent(.editingDidEndOnExit)
                .withLatestFrom(viewModel.isValidated) // Get the latest validation state
                .filter { $0 } // Only proceed if true (valid)
                .subscribe(onNext: { [weak self] _ in
                    self?.triggerContinueAction()
                })
            
            viewModel
                .isLoadingRelay
                .subscribe(onNext: { [weak self] isLoading in
                    if isLoading {
                        self?.activityIndicator.startAnimating()
                    } else {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            self?.activityIndicator.stopAnimating()
                        }
                    }
                })
            
            viewModel
                .errorMessage
                .bind(onNext: { [weak self] message in
                    if message != "" {
                        if message == "The operation couldn’t be completed. (Newsmaker.CustomError error 7.)" {
                            self?.showAlertAndNavigateBack(message: "Invalid email or password, please try again.")
                        } else {
                            self?.showAlertAndNavigateBack(message: "Something went wrong, please try again.")
                        }
                    }
                })
            
            faceIdBtn
                .rx
                .tap
                .flatMapLatest { [weak self] _ -> Observable<String> in
                    guard let self = self else { return .empty() }
                    if self.viewModel.shouldShowBiometricPopUp() {
                        return self.biometricManager.authenticationWithBiometrics()
                    } else {
                        self.showBiometricDisabledAlert()
                        return .empty()
                    }
                }
                .observe(on: MainScheduler.instance)
                .subscribe(onNext: { [weak self] result in
                    guard let self = self else { return }
                    
                    if result.isEmpty {
                        viewModel.useStoredCredentials()
                    } else {
                        self.showBiometricError(message: result)
                    }
                })
            
            viewModel
                .biometricRelay
                .observe(on: MainScheduler.instance) // Ensure UI updates happen on the main thread
                .subscribe(onNext: { [weak self] in
                    self?.showFaceIdAlert(message: "Do you want to enable biometric for future login?")
                })
        }
    }

    func showAlertAndNavigateBack(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            // Navigate back
        }
        alert.addAction(okAction)
        
        // Present the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    func showFaceIdAlert(message: String) {
        let alert = UIAlertController(title: "Enable Biometric Credentials", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            
            UserDefaults.standard.set(true, forKey: RKStorageAccount.biometricEnabled.rawValue)
            UserDefaults.standard.set(self.emailTextField.text, forKey: UserCredentialKeys.email.rawValue)
            UserDefaults.standard.set(self.passwordTextField.text, forKey: UserCredentialKeys.password.rawValue)
            UserDefaults.standard.set(self.emailTextField.text, forKey: RKStorageAccount.biometricEnabledUser.rawValue) // <-- Store email
            self.router.routeToNetwork()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive) { _ in
            UserDefaults.standard.set(self.emailTextField.text, forKey: UserCredentialKeys.email.rawValue)
            UserDefaults.standard.set(false, forKey: RKStorageAccount.biometricEnabled.rawValue)
            UserDefaults.standard.set(self.emailTextField.text, forKey: RKStorageAccount.biometricEnabledUser.rawValue) // <-- Still update

            self.router.routeToStories()
        }
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        
        // Present the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func forgotPasswordTapped(_ sender: Any) {
        
    }
    
    @IBAction func onContinueTapped(_ sender: Any) {

    }

    private func clearErrorState() {
        passwordTextField.leadingAssistiveLabel.text = ""
        passwordTextField.setOutlineColor(.gray, for: .normal)
        passwordTextField.setOutlineColor(.blue, for: .editing)
        passwordTextField.setNormalLabelColor(.gray, for: .normal)
        passwordTextField.setLeadingAssistiveLabelColor(.gray, for: .normal)
    }

    private func applyErrorState() {
        passwordTextField.leadingAssistiveLabel.text = "Entered password is incorrect"
        passwordTextField.leadingAssistiveLabel.textColor = UIColor.green
        passwordTextField.setOutlineColor(UIColor.red, for: .normal)
        passwordTextField.setOutlineColor(UIColor.red, for: .editing)
        passwordTextField.setNormalLabelColor(UIColor.red, for: .normal)
        passwordTextField.setLeadingAssistiveLabelColor(UIColor.red, for: .normal)
    }
    
    private func triggerContinueAction() {
        viewModel?.callSignInAPICall(
            email: emailTextField.text ?? "",
            password: passwordTextField.text ?? ""
        )
    }
    
    
    private func showBiometricError(message: String) {
        // Show alert if authentication fails
        let alert = UIAlertController(title: "Biometric Authentication Failed", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // Function to show an alert if biometric is disabled
    private func showBiometricDisabledAlert() {
        let alert = UIAlertController(title: "Biometric Authentication Disabled",
                                      message: "You should enter email and password.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension SigninViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder() // Move focus to password field
        } else if textField == passwordTextField {
            passwordTextField.resignFirstResponder() // Close keyboard
            
            if viewModel.isValidated.value { // ✅ Check if credentials are valid
                triggerContinueAction() // Call sign-in action only if valid
            }
        }
        return true
    }
}
