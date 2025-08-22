//
//  VKLabel.swift
//
//  Created by Vladimir Kokhanevich on 22/02/2019.
//  Copyright © 2019 Vladimir Kokhanevich. All rights reserved.
//

import UIKit

public class VKLabel: UILabel {
    
    private var labelSelectedColor: UIColor = .lightGray
    
    private var labelLineColor: UIColor = UIColor(white: 0.9, alpha: 1)
    
    private var labelErrorLineColor: UIColor = .red
    
    private var labelTextColor: UIColor = .black
    
    private var labelErrorTextColor: UIColor = .red
    
    private var labelBackgroundColor: UIColor = .white
    
    private var labelSelectedBackgroundColor: UIColor = .white
    
    private var labelLineWidth: CGFloat = 1
    
    private var labelStyleName = VKEntryViewStyleName.underline
    
    private var labelBorderWidth: CGFloat = 1
    
    private var labelSelectedBorderWidth: CGFloat = 1
    
    private lazy var labelLine: CAShapeLayer = {
        
        let line = CAShapeLayer()
        line.strokeColor = self.labelLineColor.cgColor
        line.lineWidth = self.labelLineWidth
        layer.addSublayer(line)
        return line
    }()
    
    private var labelLinePath: UIBezierPath {
        
        let path = UIBezierPath()
        let yAxis = bounds.maxY - labelLineWidth / 2
        path.move(to: CGPoint(x: bounds.minX, y: yAxis))
        path.addLine(to: CGPoint(x: bounds.maxX, y: yAxis))
        return path
    }
    
    /// Enable or disable selection animation for active input item. Default value is true.
    public var animateWhileSelected = false
    
    /// Enable or disable selection for displaying active state.
    public var isSelected = false {
        
        didSet { if oldValue != isSelected {
            updateSelectedState() }}
    }
    
    /// Enable or disable selection for displaying error state.
    public var isError = false {
        
        didSet {  updateErrorState() }
    }
    
    // MARK: - Initializers
    
    /// Prefered initializer if you don't use storyboards or nib files.
    public init(_ style: VKEntryViewStyle) {
        
        super.init(frame: CGRect.zero)
        setEntryViewStyle(style)
    }
    
    public override func awakeFromNib() {
        
        super.awakeFromNib()
        setEntryViewStyle(VKEntryViewStyle.underline)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
    }
    
    // MARK: - Overrides
    
    public override func layoutSubviews() {
        
        super.layoutSubviews()
        
        if labelStyleName == .border {
            return
        }
        labelLine.path = labelLinePath.cgPath
    }
    
    // MARK: - Public methods
    
    /// Set appearence style.
    public func setEntryViewStyle(_ style: VKEntryViewStyle) {
        
        labelStyleName = style.styleName
        textAlignment = .center
        
        switch style {
            
        case .border(let font,
                     let textColor,
                     let errorTextColor,
                     let cornerRadius,
                     let borderWidth,
                     let selectedBorderWidth,
                     let borderColor,
                     let selectedBorderColor,
                     let errorBorderColor,
                     let backgroundColor,
                     let selectedBackgroundColor):
            
            self.font = font
            self.textColor = textColor
            labelTextColor = textColor
            labelErrorTextColor = errorTextColor
            layer.cornerRadius = cornerRadius
            layer.borderColor = borderColor.cgColor
            layer.borderWidth = borderWidth
            labelBorderWidth = borderWidth
            labelSelectedBorderWidth = selectedBorderWidth
            layer.backgroundColor = backgroundColor.cgColor
            labelSelectedColor = selectedBorderColor
            labelLineColor = borderColor
            labelErrorLineColor = errorBorderColor
            labelBackgroundColor = backgroundColor
            labelSelectedBackgroundColor = selectedBackgroundColor
            
        case .underline(let font,
                        let textColor,
                        let errorTextColor,
                        let lineWidth,
                        let lineColor,
                        let selectedLineColor,
                        let errorLineColor):
            
            self.font = font
            self.textColor = textColor
            labelTextColor = textColor
            labelErrorTextColor = errorTextColor
            labelLine.strokeColor = lineColor.cgColor
            labelLine.lineWidth = lineWidth
            labelSelectedColor = selectedLineColor
            labelLineColor = lineColor
            labelErrorLineColor = errorLineColor
        }
    }
    
    // MARK: - Private methods
    
    private func updateSelectedState() {
        
        if labelStyleName == .underline {
            
            if isSelected {
                
                labelLine.strokeColor = labelSelectedColor.cgColor
                
                if animateWhileSelected {
                    
                    let animation = animateViewBorder(keyPath: #keyPath(CAShapeLayer.strokeColor))
                    labelLine.add(animation, forKey: "strokeColorAnimation")
                }
            } else {
                
                labelLine.removeAllAnimations()
                labelLine.strokeColor = labelLineColor.cgColor
            }
        } else {
            
            if isSelected {
                
                layer.borderColor = labelSelectedColor.cgColor
                layer.backgroundColor = labelSelectedBackgroundColor.cgColor
                layer.borderWidth = labelSelectedBorderWidth
                if animateWhileSelected {
                    
                    let animation = animateViewBorder(keyPath: #keyPath(CALayer.borderColor))
                    layer.add(animation, forKey: "borderColorAnimation")
                }
            } else {
                
                layer.removeAllAnimations()
                layer.borderColor = labelLineColor.cgColor
                layer.backgroundColor = labelBackgroundColor.cgColor
                layer.borderWidth = labelBorderWidth
            }
        }
    }
    
    private func updateErrorState() {
        
        if isError {
            
            if labelStyleName == .underline {
                
                labelLine.removeAllAnimations()
                labelLine.strokeColor = labelErrorLineColor.cgColor
            } else {
                
                layer.removeAllAnimations()
                layer.borderColor = labelErrorLineColor.cgColor
            }
            
            textColor = labelErrorTextColor
        } else {
            if labelStyleName == .underline {
                labelLine.strokeColor = labelLineColor.cgColor } else {
                    layer.borderColor = labelLineColor.cgColor
                }
            textColor = labelTextColor
        }
    }
    
    private func animateViewBorder(keyPath: String) -> CAKeyframeAnimation {
        
        let animation = CAKeyframeAnimation(keyPath: keyPath)
        animation.duration = 1.0
        animation.repeatCount = Float.greatestFiniteMagnitude
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.values = [labelLineColor.cgColor,
                            labelSelectedColor.cgColor,
                            labelSelectedColor.cgColor,
                            labelLineColor.cgColor]
        return animation
    }
}
