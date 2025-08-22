//
//  UIViewExtensions.swift
//  Lumen
//
//  Created by Syed Mutahir Pirzada on 09/01/2025.
//

import UIKit
import Foundation

extension UIView {
    private static let lineDashPattern: [NSNumber] = [6, 3] // 7 is the length of dash, 3 is length of the gap.
    private static let lineDashWidth: CGFloat = 1.0
    
    func makeDashedBorderLine() {
        let path = CGMutablePath()
        let shapeLayer = CAShapeLayer()
        shapeLayer.lineWidth = UIView.lineDashWidth
        shapeLayer.strokeColor = UIColor.lightGray.cgColor
        shapeLayer.lineDashPattern = UIView.lineDashPattern
        path.addLines(between: [CGPoint(x: bounds.minX, y: bounds.height / 2),
                                CGPoint(x: bounds.maxX, y: bounds.height / 2)])
        shapeLayer.path = path
        layer.addSublayer(shapeLayer)
        self.clipsToBounds = true
    }
    
    class func initFromNib<T: UIView>() -> T? {
        return Bundle.main.loadNibNamed(String(describing: self),
                                        owner: nil,
                                        options: nil)?[0] as? T
    }
    
    public func roundedViewConrner(cornerRadius: CGFloat) {
        clipsToBounds = true
        layer.cornerRadius = cornerRadius
    }
    
    func addShodow(shadowOffset offset: CGSize, withShadowColor color: UIColor, withShadowOpacity opacity: Float, withShadowRadius radius: CGFloat, withMaskedCorner corner: CACornerMask?) {
        self.layer.shadowOffset = offset
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOpacity = opacity
        self.layer.shadowRadius = 7
        
        if let maskerConrner = corner {
            if #available(iOS 11.0, *) {
                self.layer.maskedCorners = maskerConrner // top right, bottom right
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    func addShadowToSelf(offset: CGSize, color: UIColor, radius: CGFloat, opacity: Float) {
        layer.masksToBounds = false
        layer.shadowOffset = offset
        layer.shadowColor = color.cgColor
        layer.shadowRadius = radius
        layer.shadowOpacity = opacity
        
        let backgroundCGColor = backgroundColor?.cgColor
        backgroundColor = .clear
        layer.backgroundColor = backgroundCGColor
    }
    
    /// Adds constraints to this `UIView` instances `superview` object to make sure this always has the same size as the superview.
    /// Please note that this has no effect if its `superview` is `nil` – add this `UIView` instance as a subview before calling this.
    
    func bindFrameToSuperviewBounds(topSpace: CGFloat? = 0) {
        guard let superview = self.superview else {
            print("Error! `superview` was nil – call `addSubview(view: UIView)` before calling `bindFrameToSuperviewBounds()` to fix this.")
            return
        }
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.topAnchor.constraint(equalTo: superview.topAnchor, constant: topSpace ?? 0).isActive = true
        self.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: 0).isActive = true
        self.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: 0).isActive = true
        self.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: 0).isActive = true
    }
    
    func addBorder(withBorderWidth width: CGFloat, borderColor color: UIColor?) {
        clipsToBounds = true
        layer.borderColor = color?.cgColor ?? UIColor.white.cgColor
        layer.borderWidth = width
    }
    
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        clipsToBounds = true
        layer.cornerRadius = radius
        layer.maskedCorners = CACornerMask(rawValue: corners.rawValue)
    }
    
    @discardableResult
    func fit(toView view: UIView, edges: UIRectEdge = .all, offset: UIEdgeInsets = .zero) -> [NSLayoutConstraint] {
        translatesAutoresizingMaskIntoConstraints = false
        var constraints = [NSLayoutConstraint]()
        if edges.contains(.top) {
            constraints.append(topAnchor.constraint(equalTo: view.topAnchor, constant: offset.top))
        }
        if edges.contains(.left) {
            constraints.append(leftAnchor.constraint(equalTo: view.leftAnchor, constant: offset.left))
        }
        if edges.contains(.bottom) {
            constraints.append(bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -offset.bottom))
        }
        if edges.contains(.right) {
            constraints.append(rightAnchor.constraint(equalTo: view.rightAnchor, constant: -offset.right))
        }
        NSLayoutConstraint.activate(constraints)
        return constraints
    }

    @discardableResult
    func fitToSuperView(edges: UIRectEdge = .all, offset: UIEdgeInsets = .zero) -> [NSLayoutConstraint] {
        guard let superview = self.superview else {
            return []
        }
        return fit(toView: superview, edges: edges, offset: offset)
    }
    
    func animateTransformIdentity(withDuration duration: TimeInterval, delay: TimeInterval = 0) {
        self.transform = CGAffineTransform(translationX: 0, y: self.bounds.height)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delay) {
            UIView.animate(withDuration: duration, delay: 0) {
                self.transform = .identity
            }
        }
    }
}

extension UIView {
    func popIn(duration: TimeInterval = 0.5) {
        self.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        UIView.animate(withDuration: duration, delay: 0.1, usingSpringWithDamping: 0.5, initialSpringVelocity: 5, options: .curveEaseOut, animations: {
            self.alpha = 1
            self.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        }, completion: nil)
    }
    
    func popOut(duration: TimeInterval = 0.5) {
        UIView.animate(withDuration: duration, delay: 1.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 5, options: .curveEaseOut, animations: {
            self.alpha = 0
            self.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        }, completion: nil)
    }
}

class RoundedView: UIView {
    override func layoutSubviews() {
        super.layoutSubviews()
        cornerRadius = bounds.height * 0.5
    }
}



class ProfileHeaderView: UIView {
    override func layoutSubviews() {
        super.layoutSubviews()
        applyRoundedBottomShape()
    }

    private func applyRoundedBottomShape() {
        let path = UIBezierPath()
        let curveHeight: CGFloat = 50 // Adjust curve depth

        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: bounds.width, y: 0))
        path.addLine(to: CGPoint(x: bounds.width, y: bounds.height - curveHeight))
        path.addQuadCurve(
            to: CGPoint(x: 0, y: bounds.height - curveHeight),
            controlPoint: CGPoint(x: bounds.width / 2, y: bounds.height + curveHeight)
        )
        path.close()

        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.fillColor = UIColor.systemBlue.withAlphaComponent(0.1).cgColor // Adjust background color

        layer.insertSublayer(shapeLayer, at: 0)
    }
}

import UIKit

extension UIView {
    func startShimmeringEffect() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.bounds
        gradientLayer.colors = [
            UIColor(white: 0.85, alpha: 1.0).cgColor,
            UIColor(white: 0.95, alpha: 1.0).cgColor,
            UIColor(white: 0.85, alpha: 1.0).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradientLayer.locations = [0.0, 0.5, 1.0]

        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [-1.0, -0.5, 0.0]
        animation.toValue = [1.0, 1.5, 2.0]
        animation.duration = 1.2
        animation.repeatCount = .infinity

        gradientLayer.add(animation, forKey: "shimmer")
        self.layer.mask = gradientLayer
    }

    func stopShimmeringEffect() {
        self.layer.mask = nil
    }
}

