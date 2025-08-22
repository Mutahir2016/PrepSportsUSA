//
//  AuthVerificationViewController.swift
//  Lumen
//
//  Created by Syed Mutahir Pirzada on 25/12/2024.
//

import UIKit

class AuthVerificationViewController: BaseViewController {
    
    @IBOutlet weak var verifyPinCodeFieldView: VKPinCodeView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var verifyMessageLabel: UILabel!
    var errorMessageLabel = UILabel()
    @IBOutlet weak var codeView: UIView!
    @IBOutlet weak var activityIndicator: LoadingIndicatorView!

    var viewModel: AuthVerificationViewModel!
    let borderStyle = VKEntryViewStyle.border(
        font: .systemFont(ofSize: 10),
        textColor: .black,
        errorTextColor: .black,
        cornerRadius: 6,
        borderWidth: 1,
        selectedBorderWidth: 1,
        borderColor: UIColor(red: 0.11, green: 0.12, blue: 0.14, alpha: 0.1),
        selectedBorderColor: UIColor(red: 0.0, green: 114/255, blue: 36/255, alpha: 0.47),
        errorBorderColor: .black,
        backgroundColor: UIColor.clear,
        selectedBackgroundColor: UIColor.clear)
    
    override func callingInsideViewDidLoad() {
        setupVerifyPinCodeView()
        setupUI()
    }
    
    override func setUp() {
        viewModel = AuthVerificationViewModel()
    }
    
    private func setupUI() {
        titleLabel.font = UIFont.ibmBold(size: 26.0)
        verifyMessageLabel.font = UIFont.ibmMedium(size: 16)
        displayResendView()
        bindView()
    }
    
    private func displayResendView() {
        // Create a label
        let messageLabel = UILabel()
        messageLabel.text = "Didn't get a verification code?"
        messageLabel.font = UIFont.ibmRegular(size: 14.0)
        messageLabel.textColor = UIColor.outLineColor

        // Create a button
        let resendButton = UIButton(type: .system)
        let resendTitle = "Resend"
        let attributedTitle = NSAttributedString(
            string: resendTitle,
            attributes: [
                .font: UIFont.ibmMedium(size: 14.0),
                .foregroundColor: UIColor.appBlueColor,
                .underlineStyle: NSUnderlineStyle.single.rawValue
            ]
        )
        resendButton.setAttributedTitle(attributedTitle, for: .normal)
        resendButton.addTarget(self, action: #selector(resendButtonTapped), for: .touchUpInside)

        // Create an error label
        let errorMessageLabel = UILabel()
        errorMessageLabel.text = "" // Initially empty
        errorMessageLabel.font = UIFont.ibmRegular(size: 12.0)
        errorMessageLabel.textColor = UIColor.red
        errorMessageLabel.numberOfLines = 0
        errorMessageLabel.textAlignment = .left
        errorMessageLabel.isHidden = true // Hide by default

        // Create a container view for label and button
        let containerView = UIStackView(arrangedSubviews: [messageLabel, resendButton])
        containerView.axis = .horizontal
        containerView.spacing = 5 // Minimal spacing between label and button
        containerView.alignment = .center

        // Create a vertical stack view to include error label and container
        let stackView = UIStackView(arrangedSubviews: [containerView, errorMessageLabel])
        stackView.axis = .vertical
        stackView.spacing = 5
        stackView.alignment = .center

        // Add the stack view to the view
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)

        // Position the stack view below codeView with 5 points spacing
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20), // Align to left with padding
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20), // Ensure it doesn’t overflow
            stackView.topAnchor.constraint(equalTo: codeView.bottomAnchor, constant: 5) // 5 points below codeView
        ])

        // Store reference to the error message label for future updates
        self.errorMessageLabel = errorMessageLabel
    }

    // Function to update error message
    private func showError(_ message: String) {
        errorMessageLabel.text = message
        errorMessageLabel.isHidden = false
    }

    // Function to clear error message
    private func clearError() {
        errorMessageLabel.text = ""
        errorMessageLabel.isHidden = true
    }

    
    private func bindView() {
        disposeBag.insert {
            viewModel.emailFieldText
                .subscribe(onNext: { [weak self] text in
                    self?.updateVerifyMessageLabel(with: text)
                })
            
            viewModel
                .forgotPasswordMessage
                .bind(onNext: { [weak self] message in
                    if message != "" {
                        self?.errorMessageLabel.text = message
                        self?.errorMessageLabel.isHidden = false
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                            self?.verifyPinCodeFieldView.isCodeEntered = false
                            self?.verifyPinCodeFieldView.isError = true
                            self?.resetVerifyPinCodeView()
                        }
                    }
                })
            
            viewModel
                .isLoadingRelay
                .subscribe(onNext: { [weak self] isLoading in
                    if isLoading {
                        self?.activityIndicator.startAnimating()
                    } else {
                        self?.activityIndicator.stopAnimating()
                    }
                })
            
            viewModel
                .errorMessage
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
        }
        alert.addAction(okAction)
        
        // Present the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    private func updateVerifyMessageLabel(with text: String) {
        let message = "A message with a verification code has been sent to \(text). Enter the code below."
        
        // Create an attributed string with default attributes
        let attributedMessage = NSMutableAttributedString(
            string: message,
            attributes: [
                .font: UIFont.ibmRegular(size: 14.0), // Default font
                .foregroundColor: UIColor.outLineColor.withAlphaComponent(0.6) // Default color
            ]
        )
        
        // Find the range of the dynamic text
        if let dynamicTextRange = message.range(of: text) {
            let nsRange = NSRange(dynamicTextRange, in: message)
            
            // Apply dark gray color to the dynamic text
            attributedMessage.addAttributes(
                [
                    .foregroundColor: UIColor.outLineColor // Highlight color
                ],
                range: nsRange
            )
        }
        
        // Set the attributed text to the label
        verifyMessageLabel.attributedText = attributedMessage
    }
    
    
    @objc func resendButtonTapped() {
        print("Resend button tapped")
        // Add logic to resend the verification code
        errorMessageLabel.isHidden = true
        viewModel.resendAuth()
    }
    
    // MARK: - Set up pin View
    private func setupVerifyPinCodeView() {
        verifyPinCodeFieldView.otpDelegate = self
        verifyPinCodeFieldView.spacing = 10
        verifyPinCodeFieldView.shakeOnError = true
        verifyPinCodeFieldView.setStyle(borderStyle)
        verifyPinCodeFieldView.onBecomeActive()
        
        verifyPinCodeFieldView.onCodeEnteredFirstTime = { [weak self] pinCode in
            guard let self = self else { return }
            if self.viewModel.validatePinCode(pinCode) {
                self.viewModel.verifyPinCode(pinCode)
            } else {
                self.verifyPinCodeFieldView.isCodeEntered = false
                self.verifyPinCodeFieldView.isError = true
                self.resetVerifyPinCodeView()
            }
        }
        verifyPinCodeFieldView.validator = validator(_:)
    }
    
    private func resetVerifyPinCodeView() {
        self.verifyPinCodeFieldView.clearCode()
        DispatchQueue.main.async {
            self.verifyPinCodeFieldView.onBecomeActive()
        }
    }
    
    private func validator(_ code: String) -> Bool {
        return !code.trimmingCharacters(in: CharacterSet.decimalDigits.inverted).isEmpty
    }
    
}


extension AuthVerificationViewController: VKOTPTextFieldDelegate {
    func didEnter(code: String) {
        errorMessageLabel.isHidden = true
    }
    
    func didFinishErrorAnimation() {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
            self.errorMessageLabel.text = "Invalid verification code. Please try again."
            self.errorMessageLabel.isHidden = false
            self.resetVerifyPinCodeView()
        }
    }
}
