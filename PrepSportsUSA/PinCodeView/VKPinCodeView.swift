//
//  VKPinCodeView.swift
//
//  Created by Vladimir Kokhanevich on 22/02/2019.
//  Copyright © 2019 Vladimir Kokhanevich. All rights reserved.
//

import UIKit

public protocol VKOTPTextFieldDelegate: AnyObject {
    func didEnter(code: String)
    func didFinishErrorAnimation()
}

/// Vadation closure. Use it as soon as you need to validate input text which is different from digits.
public typealias VKPinCodeValidator = (_ code: String) -> Bool

/// Main container with PIN input items.
/// You can use it in storyboards, nib files or right in code.
public class VKPinCodeView: UIView {
    
    private lazy var stackView = UIStackView(frame: bounds)
    
    private lazy var pinCodeTextField = UITextField(frame: bounds)
    
    private var codeViewStyle: VKEntryViewStyle?
    
    public weak var otpDelegate: VKOTPTextFieldDelegate?
    
    public var isCodeEntered = false
    
    var enteredCode = ""
    
    private var pinCodeText = "" {
        
        didSet {
            onCodeDidChange?(pinCodeText)
        }
    }
    
    private var activeIndex: Int {
        return pinCodeText.isEmpty ? 0 : pinCodeText.count - 1
    }
    
    /// Number of input items.
    public var length: Int = 7 {
        
        willSet {
            createLabels()
        }
    }
    
    /// Spacing between input items.
    public var spacing: CGFloat = 10 {
        
        willSet {
            if newValue != spacing {
                stackView.spacing = newValue
            }
        }
    }
    
    public var keyBoardType = UIKeyboardType.numberPad {
        willSet {
            pinCodeTextField.keyboardType = newValue
        }
    }
    
    /// Enable or disable error mode. Default value is false.
    public var isError = false {
        
        didSet {
            if oldValue != isError {
                updateErrorState()
            }
        }
    }
    
    /// Enable or disable selection animation for active input item. Default value is true.
    public var animateSelectedInputItem = false
    
    /// Enable or disable shake animation on error. Default value is true.
    public var shakeOnError = true
    
    /// Fires when PIN is  entered first time.
    public var onCodeEnteredFirstTime: ((_ enteredcode: String) -> Void)?
    
    /// Fires when PIN is completely entered.
    public var onComplete: ((_ enteredcode: String, _ isCodeValid: Bool) -> Void)?
    
    /// Fires after each char has been entered.
    public var onCodeDidChange: ((_ code: String) -> Void)?
    
    /// Fires after begin editing.
    public var onBeginEditing: (() -> Void)?
    
    /// Vadation closure. Use it as soon as you need to validate input text which is different from digits.
    /// You dodn't need this by default.
    public var validator: VKPinCodeValidator?
    
    // MARK: - Initializers
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    /// Prefered initializer if you don't use storyboards or nib files.
    public init(style: VKEntryViewStyle) {
        super.init(frame: CGRect.zero)
        codeViewStyle = style
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - Life cycle
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    // MARK: - Overrides
    
    @discardableResult override public func becomeFirstResponder() -> Bool {
        onBecomeActive()
        return super.becomeFirstResponder()
    }
    
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        onBecomeActive()
    }
    
    // MARK: - Public methods
    
    /// Use this method as soon as you need a custom appearence.
    /// It is definitely need if you use storyboards or nib files.
    public func setStyle(_ style: VKEntryViewStyle) {
        
        codeViewStyle = style
        createLabels()
    }
    
    // MARK: - Private methods
    
    private func setup() {
        
        setupTextField()
        setupStackView()
        createLabels()
    }
    
    private func setupStackView() {
        
        stackView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        stackView.alignment = .fill
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = spacing
        addSubview(stackView)
    }
    
    private func setupTextField() {
        
        pinCodeTextField.keyboardType = keyBoardType
        pinCodeTextField.isHidden = true
        pinCodeTextField.delegate = self
        pinCodeTextField.isSecureTextEntry = true
        pinCodeTextField.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        pinCodeTextField.addTarget(self, action: #selector(self.onTextChanged(_:)), for: .editingChanged)
//        pinCodeTextField.setFont(CustomFont.medium18Body)
        
        if #available(iOS 12.0, *) {
            pinCodeTextField.textContentType = .oneTimeCode
        }
        
        addSubview(pinCodeTextField)
    }
    
    @objc private func onTextChanged(_ sender: UITextField) {
        let text = sender.text ?? ""

        if pinCodeText.count > text.count {
            deleteChar(text)
        } else {
            appendChar(text)
            highlightActiveLabel(text.count)
        }

        if text.count == length {
            pinCodeText = text // ✅ Ensure state is updated
            if !isCodeEntered {
                codeEnteredFirstTime()
            } else {
                codeEnteredForConfirmation()
            }
            turnOffSelectedLabel()
            pinCodeTextField.resignFirstResponder()
        }

        otpDelegate?.didEnter(code: text)
    }

    
    private func codeEnteredFirstTime() {
        isCodeEntered = true
        enteredCode = pinCodeText
        onCodeEnteredFirstTime?(enteredCode)
    }
    
    private func codeEnteredForConfirmation() {
        onComplete?(pinCodeText, enteredCode == pinCodeText)
    }
    
    private func deleteChar(_ text: String) {
        let index = text.count
        if let previous = stackView.arrangedSubviews[index] as? UILabel {
            previous.text = ""
            pinCodeText = text
            var indexx = pinCodeText.count
            if indexx < 0 {
                indexx = 0
            }
            highlightActiveLabel(indexx)
        }
    }
    
    private func appendChar(_ text: String) {
        guard !text.isEmpty else { return }
        let activeLabel = text.count - 1
        if let label = stackView.arrangedSubviews[activeLabel] as? UILabel {
            let index = text.index(text.startIndex, offsetBy: activeLabel)
            let char = String(text[index])
            label.text = char
            self.pinCodeText += char
            print("Code is \(self.pinCodeText)")
        }
    }
    
    public func clearCode() {
        pinCodeText = ""
        for index in 0 ..< stackView.arrangedSubviews.count {
            if let label = stackView.arrangedSubviews[index] as? VKLabel {
                label.isSelected = index == 0
                label.text = ""
            }
        }
        becomeFirstResponder()
    }
    
    private func highlightActiveLabel(_ activeIndex: Int) {
        for index in 0 ..< stackView.arrangedSubviews.count {
            if let label = stackView.arrangedSubviews[index] as? VKLabel {
                label.isSelected = index == activeIndex
            }
        }
    }
    
    private func turnOffSelectedLabel() {
        if let label = stackView.arrangedSubviews[activeIndex] as? VKLabel {
            label.isSelected = false
        }
    }
    
    private func createLabels() {
        let style = codeViewStyle ?? VKEntryViewStyle.border
        stackView.arrangedSubviews.forEach {
            $0.removeFromSuperview()
        }
        for _ in 1 ... length {
            stackView.addArrangedSubview(VKLabel(style))
        }
    }
    
    private func updateErrorState() {
        if isError {
            turnOffSelectedLabel()
            if shakeOnError {
                shakeAnimation()
            }
        }
        stackView.arrangedSubviews.forEach {
            ($0 as? VKLabel)?.isError = isError
        }
    }
    
    private func shakeAnimation() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.duration = 0.5
        animation.values = [-15.0, 15.0, -15.0, 15.0, -12.0, 12.0, -10.0, 10.0, 0.0]
        layer.add(animation, forKey: "shake")
        otpDelegate?.didFinishErrorAnimation()
    }
    
    func onBecomeActive() {
        pinCodeTextField.becomeFirstResponder()
        highlightActiveLabel(activeIndex)
    }
}

extension VKPinCodeView: UITextFieldDelegate {
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        isError = false
        onBeginEditing?()
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.isEmpty {
            return true
        }
        return (validator?(string) ?? true) && pinCodeText.count < length
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        if isError {
            return
        }
        turnOffSelectedLabel()
    }
}
