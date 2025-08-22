//
//  LoadingView.swift
//  Rikstoto
//
//  Created by Apphuset on 2023-07-12.
//

import UIKit

final class LoadingView: UIView {
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialize()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    private let animator = UIViewPropertyAnimator(duration: 1, curve: .linear)
    let blurEffectView = UIVisualEffectView()
    private func initialize() {
        
//        let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
        addSubview(blurEffectView)
        blurEffectView.fitToSuperView()
        
        let loading = LoadingIndicatorView()
        loading.startAnimating()
        addSubview(loading)
        loading.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            loading.centerXAnchor.constraint(equalTo: centerXAnchor),
            loading.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        animator.addAnimations {
            self.blurEffectView.effect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        }
        animator.fractionComplete = 0.1
        
        backgroundColor = .black.withAlphaComponent(0.2)
    }
    
    deinit {
        animator.stopAnimation(true)
    }

}

extension UIView {
    
    fileprivate enum AssociatedKeys {
        static var loadingView = "RKLoadingView"
    }

    fileprivate var loadingView: LoadingView? {
        objc_getAssociatedObject(self, &AssociatedKeys.loadingView) as? LoadingView
    }

    func showCustomLoading() {
        if let loading = loadingView, loading.superview == self {
            self.bringSubviewToFront(loading)
            return
        }
        
        let loadingView = LoadingView(frame: bounds)
        loadingView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(loadingView)
        
        objc_setAssociatedObject(self, &AssociatedKeys.loadingView, loadingView, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    func hideCustomLoading() {
        loadingView?.removeFromSuperview()
    }
}

// Helper loading for app window
extension LoadingView {
    fileprivate static func keyWindow() -> UIWindow? {
        UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }.last { $0.isKeyWindow }
    }
    static func show() {
        keyWindow()?.showCustomLoading()
    }
    
    static func hide() {
        keyWindow()?.hideCustomLoading()
    }
}
