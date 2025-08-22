//
//  CustomButton.swift
//  Lumen
//
//  Created by Syed Mutahir Pirzada on 23/12/2024.
//

import Foundation
import UIKit

class CustomButton: UIButton {
    
    enum ButtonState {
        case normal
        case disabled
    }
    var isChecked = false
    private var disabledBackgroundColor: UIColor?
    private var defaultBackgroundColor: UIColor? {
        didSet {
            backgroundColor = defaultBackgroundColor
        }
    }
    
    override var isEnabled: Bool {
        didSet {
            if isEnabled {
                if let color = defaultBackgroundColor {
                    self.backgroundColor = color
                }
                // Explicitly set the title color when enabled
                self.setTitleColor(UIColor.white, for: .normal)
            } else {
                if let color = disabledBackgroundColor {
                    self.backgroundColor = color
                }
                // Explicitly set the title color when disabled
                self.setTitleColor(UIColor.appBtnDisabledTitleColor, for: .disabled)
            }
            
        }
    }
    
    // Our custom functions to set color for different state
    func setBackgroundColor(_ color: UIColor?, for state: ButtonState) {
        switch state {
        case .disabled:
            disabledBackgroundColor = color
        case .normal:
            defaultBackgroundColor = color
        }
    }
    
    func toggle() {
        isChecked = !isChecked
    }
    
    /// overide the layer corner radius and set round corner as capsule style (corner radius = height * 0.5)
    var isAutoRoundedCorner = false {
        didSet {
            if isAutoRoundedCorner {
                cornerRadius = bounds.height * 0.5
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if isAutoRoundedCorner {
            cornerRadius = bounds.height * 0.5
        }
    }
}

// MARK: - ibinspectable

extension UIView {
    @IBInspectable var cornerRadius: CGFloat {
        get { layer.cornerRadius }
        set { layer.cornerRadius = newValue }
    }

    @IBInspectable var shadowColor: UIColor? {
        get {
            if let color = layer.shadowColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set { layer.shadowColor = newValue?.cgColor }
    }

    @IBInspectable var shadowOffset: CGSize {
        get { layer.shadowOffset }
        set { layer.shadowOffset = newValue }
    }
    
    @IBInspectable var shadowRadius: CGFloat {
        get { layer.shadowRadius }
        set { layer.shadowRadius = newValue }
    }

    @IBInspectable var shadowOpacity: CGFloat {
        get { CGFloat(layer.shadowOpacity) }
        set { layer.shadowOpacity = Float(newValue) }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get { layer.borderWidth }
        set { layer.borderWidth = newValue }
    }

    @IBInspectable var borderColor: UIColor? {
        get {
            if let color = layer.borderColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set { layer.borderColor = newValue?.cgColor }
    }
}
