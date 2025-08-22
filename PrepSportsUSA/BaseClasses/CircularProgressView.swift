//
//  CircularProgressView.swift
//  ShredFast
//
//  Created by Syed Mutahir Pirzada on 07/11/2024.
//

import UIKit

@IBDesignable
class CircularProgressView: UIView {
    private let progressLayer = CAShapeLayer()
    private let backgroundLayer = CAShapeLayer()

    @IBInspectable var progressColor: UIColor = .green {
        didSet {
            progressLayer.strokeColor = progressColor.cgColor
        }
    }
    
    @IBInspectable var backgroundColorCircle: UIColor = .lightGray {
        didSet {
            backgroundLayer.strokeColor = backgroundColorCircle.cgColor
        }
    }
    
    @IBInspectable var lineWidth: CGFloat = 10 {
        didSet {
            backgroundLayer.lineWidth = lineWidth
            progressLayer.lineWidth = lineWidth
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayers()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayers()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupLayers()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupLayerPaths()
    }
    
    private func setupLayers() {
        backgroundLayer.fillColor = UIColor.clear.cgColor
        backgroundLayer.strokeColor = backgroundColorCircle.cgColor
        backgroundLayer.lineCap = .round
        backgroundLayer.lineWidth = lineWidth
        layer.addSublayer(backgroundLayer)

        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = progressColor.cgColor
        progressLayer.lineCap = .round
        progressLayer.lineWidth = lineWidth
        progressLayer.strokeEnd = 0
        layer.addSublayer(progressLayer)
    }
    
    private func setupLayerPaths() {
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: bounds.midX, y: bounds.midY),
                                      radius: min(bounds.width, bounds.height) / 2 - lineWidth / 2,
                                      startAngle: -.pi / 2,
                                      endAngle: 3 * .pi / 2,
                                      clockwise: true)
        backgroundLayer.path = circlePath.cgPath
        progressLayer.path = circlePath.cgPath
    }

    func setProgress(_ progress: CGFloat, animated: Bool = true, duration: CFTimeInterval = 1.0) {
        let clampedProgress = min(max(progress, 0), 1) // Clamp progress between 0 and 1
        progressLayer.strokeEnd = clampedProgress
        if animated {
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.fromValue = 0
            animation.toValue = clampedProgress
            animation.duration = duration
            animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            progressLayer.add(animation, forKey: "progressAnimation")
        }
    }
}

