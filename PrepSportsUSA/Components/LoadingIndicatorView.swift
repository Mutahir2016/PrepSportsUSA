//
// LoadingIndicatorView.swift
// Rikstoto
//
// Created by Apphuset on 2023-07-16.
//
    
import UIKit

final class LoadingIndicatorView: UIView {
    // MARK: - Colors (update third one as you like)
    private let colors: [UIColor] = [
        #colorLiteral(red: 0.8, green: 0.0, blue: 0.0, alpha: 1), // Red
        #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1),
        #colorLiteral(red: 0.0, green: 0.2, blue: 0.5, alpha: 1), // Dark Blue
         // Option 1: White
        // UIColor(red: 0.31, green: 0.86, blue: 0.95, alpha: 1) // Option 2: Cyan
        // UIColor(red: 1.0, green: 0.6, blue: 0.2, alpha: 1)     // Option 3: Orange
    ]
    
    private var dotLayers = [CALayer]()
    private let dotSize: CGFloat = 16
    private let dotSpacing: CGFloat = 16
    
    private let backgroundView = UIView()
    
    @IBInspectable
    private(set) var isAnimating = false {
        didSet { updateVisibility() }
    }
    
    @IBInspectable
    var hidesWhenStopped = true {
        didSet { updateVisibility() }
    }
    
    // MARK: - Init
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialize()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    override var intrinsicContentSize: CGSize {
        CGSize(
            width: (dotSpacing + dotSize) * CGFloat(colors.count - 1) + dotSize + 8,
            height: dotSize + 8
        )
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundView.frame = bounds
        positionDotLayers()
    }
    
    // MARK: - Setup
    private func initialize() {
        backgroundColor = .clear
        isUserInteractionEnabled = true // Blocks touches behind it
        
        backgroundView.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        backgroundView.frame = bounds
        backgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(backgroundView)
        
        colors.forEach { color in
            let dotLayer = CALayer()
            dotLayer.bounds = CGRect(x: 0, y: 0, width: dotSize, height: dotSize)
            dotLayer.cornerRadius = dotSize * 0.5
            dotLayer.backgroundColor = color.cgColor
            layer.addSublayer(dotLayer)
            dotLayers.append(dotLayer)
        }
        
        positionDotLayers()
        updateVisibility()
    }
    
    private func positionDotLayers() {
        let dotContainerWidth = (dotSpacing + dotSize) * CGFloat(dotLayers.count - 1)
        let startX = (bounds.width - dotContainerWidth) / 2
        
        for (index, dotLayer) in dotLayers.enumerated() {
            dotLayer.position = CGPoint(
                x: startX + CGFloat(index) * (dotSpacing + dotSize),
                y: bounds.midY
            )
        }
    }
    
    // MARK: - Animation
    func startAnimating() {
        guard !isAnimating else { return }
        
        isAnimating = true
        
        DispatchQueue.main.async {
            for (index, dotLayer) in self.dotLayers.enumerated() {
                let animation = self.animation(delay: TimeInterval(index) * 0.8)
                dotLayer.add(animation, forKey: "move")
            }
        }
    }
    
    func stopAnimating() {
        dotLayers.forEach { $0.removeAllAnimations() }
        isAnimating = false
    }
    
    private func animation(delay: TimeInterval) -> CAAnimation {
        let duration: TimeInterval = 3.5
        
        let animation = CAKeyframeAnimation(keyPath: "position.y")
        animation.values = [0, dotSize * 0.5, -dotSize * 2, dotSize * 0.25, 0, 0]
        animation.keyTimes = [
            NSNumber(value: 0),
            NSNumber(value: 0.2 / duration),
            NSNumber(value: 0.65 / duration),
            NSNumber(value: 1.0 / duration),
            NSNumber(value: 1.3 / duration),
            NSNumber(value: 1)
        ]
        animation.timingFunctions = Array(
            repeating: CAMediaTimingFunction(name: .easeInEaseOut),
            count: 5
        )
        animation.duration = duration
        animation.isAdditive = true
        animation.repeatCount = .infinity
        animation.isRemovedOnCompletion = false
        animation.beginTime = CACurrentMediaTime() + delay
        return animation
    }
    
    // MARK: - Visibility
    private func updateVisibility() {
        let isHidden = hidesWhenStopped && !isAnimating
        dotLayers.forEach { $0.isHidden = isHidden }
        backgroundView.isHidden = isHidden
        self.isHidden = isHidden
    }
}
