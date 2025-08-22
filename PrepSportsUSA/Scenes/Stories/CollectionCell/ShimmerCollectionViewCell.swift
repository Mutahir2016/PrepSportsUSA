//
//  ShimmerCollectionViewCell.swift
//  Lumen
//
//  Created by Syed Mutahir Pirzada on 04/02/2025.
//

import UIKit

class ShimmerCollectionViewCell: UICollectionViewCell {
    
    private let titleLabel = UIView()
    private let numberLabel = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupShimmerUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupShimmerUI()
    }

    private func setupShimmerUI() {
        self.layer.cornerRadius = 16
        self.backgroundColor = UIColor.systemGray5
        
        titleLabel.backgroundColor = UIColor.lightGray.withAlphaComponent(0.6)
        numberLabel.backgroundColor = UIColor.lightGray.withAlphaComponent(0.8)

        titleLabel.layer.cornerRadius = 5
        numberLabel.layer.cornerRadius = 8

        self.addSubview(titleLabel)
        self.addSubview(numberLabel)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        numberLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
            titleLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            titleLabel.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.6),
            titleLabel.heightAnchor.constraint(equalToConstant: 15),

            numberLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            numberLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            numberLabel.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.7),
            numberLabel.heightAnchor.constraint(equalToConstant: 30)
        ])
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        startShimmer()
    }

    func startShimmer() {
        applyShimmer(to: titleLabel)
        applyShimmer(to: numberLabel)
    }

    /// ✅ Creates a shimmer effect on a specific UIView
    private func applyShimmer(to view: UIView) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: -view.bounds.width, y: 0, width: view.bounds.width * 2, height: view.bounds.height)
        
        gradientLayer.colors = [
            UIColor(white: 0.85, alpha: 1.0).cgColor,
            UIColor(white: 0.95, alpha: 1.0).cgColor,
            UIColor(white: 0.85, alpha: 1.0).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)

        let animation = CABasicAnimation(keyPath: "transform.translation.x")
        animation.fromValue = -view.bounds.width * 2
        animation.toValue = view.bounds.width * 2
        animation.duration = 1.2 // Adjust speed if needed
        animation.repeatCount = .infinity
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

        gradientLayer.add(animation, forKey: "shimmer")
        
        view.layer.mask = gradientLayer
    }

    func stopShimmer() {
        self.layer.mask = nil
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.layer.mask = nil
        numberLabel.layer.mask = nil
        startShimmer()
    }
}



