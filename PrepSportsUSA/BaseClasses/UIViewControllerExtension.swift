//
//  UIViewControllerExtension.swift
//  Lumen
//
//  Created by Syed Mutahir Pirzada on 24/12/2024.
//


import Foundation
import UIKit
import LocalAuthentication

extension UIViewController {
    
    class func getViewControllerFrom(name: PrepSportsUSARouting) -> UIViewController {
        let storyboard = UIStoryboard(name: name.rawValue, bundle: nil)
        let rootViewController = storyboard.instantiateViewController(withIdentifier: "\(name.rawValue)ViewController")
        return rootViewController
    }
    
    static func getViewControllerFor(name: PrepSportsUSARouting) -> UIViewController? {
        do {
            let storyboard = UIStoryboard(name: name.rawValue, bundle: nil)
            
            switch name {
            case .network:
                return storyboard.instantiateViewController(withIdentifier: "\(name.rawValue)ViewController") as! NetworkViewController
            case .signIn:
                return storyboard.instantiateViewController(withIdentifier: "\(name.rawValue)ViewController") as! SigninViewController
            case .search:
                return storyboard.instantiateViewController(withIdentifier: "\(name.rawValue)ViewController")
            case .stories:
                return storyboard.instantiateViewController(withIdentifier: "\(name.rawValue)ViewController")
            case .storiesHome:
                return storyboard.instantiateViewController(withIdentifier: "\(name.rawValue)ViewController")
            case .more:
                return storyboard.instantiateViewController(withIdentifier: "\(name.rawValue)ViewController")
            case .projectStories:
                return storyboard.instantiateViewController(withIdentifier: "\(name.rawValue)ViewController")
            case .sports:
                return storyboard.instantiateViewController(withIdentifier: "\(name.rawValue)ViewController") as! SportsViewController
                
            case .addSportsBrief:
                return storyboard.instantiateViewController(withIdentifier: "\(name.rawValue)ViewController") as! AddSportsBriefViewController
            default:
                return nil
            }
        } catch {
            print("Error loading storyboard for \(name.rawValue): \(error)")
            return nil
        }
    }
    
    class func getViewControllerBy(storyboard: String, identifier: String) -> UIViewController {
        let storyboard = UIStoryboard(name: storyboard, bundle: nil)
        let rootViewController = storyboard.instantiateViewController(withIdentifier: identifier)
        return rootViewController
    }
    
    func present(_ viewControllerToPresent: UIViewController) {
        present(viewControllerToPresent, animated: true, completion: nil)
    }
    
    public func dismiss(completion: (() -> Void)? = nil) {
        presentingViewController?.dismiss(animated: true, completion: completion)
    }
    
    class func displayAlertControllerWith(_ title: String, andMessage message: String) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "LokaliseQuick.Home.genericCancel.rawValue.localized", style: .default))
        return alert
    }
    
    func setDate(_ date: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd" // Input format matches the JSON date format
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "MMM dd, yyyy" // Desired output format
        
        if let dateObject = inputFormatter.date(from: date) {
            return outputFormatter.string(from: dateObject)
        }
        return date // Return the original date if parsing fails
    }
    
    class func evaluateAuthenticationPolicyMessageForLA(errorCode: Int) -> String {
        var message = ""
        switch errorCode {
            
        case LAError.authenticationFailed.rawValue:
            message = "The user failed to provide valid credentials"
            
        case LAError.appCancel.rawValue:
            message = "Authentication was cancelled by application"
            
        case LAError.invalidContext.rawValue:
            message = "The context is invalid"
            
        case LAError.notInteractive.rawValue:
            message = "Not interactive"
            
        case LAError.passcodeNotSet.rawValue:
            message = "Passcode is not set on the device"
            
        case LAError.systemCancel.rawValue:
            message = "Authentication was cancelled by the system"
            
        case LAError.userCancel.rawValue:
            message = "The user did cancel"
            
        case LAError.userFallback.rawValue:
            message = "The user chose to use the fallback"
            
        default:
            message = "Unknown error"
        }
        return message
    }
    
    func dismissAll(_ completion: @escaping () -> Void) {
        guard self.presentingViewController != nil else {
            completion()
            return
        }
        var viewController = self
        while (viewController.presentingViewController != nil) {
            viewController = viewController.presentingViewController!
        }
        viewController.dismiss(animated: true) {
            completion()
        }
    }
    
    var hasSafeArea: Bool {
        if UIApplication.shared.windows[0].safeAreaInsets.bottom > 0 {
            return true
        }
        return false
    }
    
    var topMostViewController: UIViewController {

        if let presented = self.presentedViewController {
            return presented.topMostViewController
        } else if let navigation = self as? UINavigationController {
            return navigation.visibleViewController?.topMostViewController ?? navigation
        } else if let tab = self as? UITabBarController {
            return tab.selectedViewController?.topMostViewController ?? tab
        } else {
            return self
        }
    }
}

extension NSObject {
    var className: String {
        return String(describing: type(of: self))
    }
    
    class var className: String {
        return String(describing: self)
    }
    
    class var nib: UINib {
        UINib(nibName: className, bundle: nil)
    }
}

extension UIButton {
    func updateButtonStyle(withCornerRadious corner: CGFloat, borderColor color: UIColor, backgroundColor bgColor: UIColor, borderWidth width: CGFloat) {
        self.layer.borderColor = color.cgColor
        self.layer.backgroundColor = bgColor.cgColor
        self.layer.borderWidth = width
        self.layer.cornerRadius = corner
    }
}

extension UINavigationController {
    func popViewControllerWithHandler(animated: Bool = true, completion: @escaping () -> Void) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        self.popViewController(animated: animated)
        CATransaction.commit()
    }
}

extension UIViewController {
    func setupCustomNavigationBar(
        withLogo logoImage: UIImage?,
        rightBarButtonImage: UIImage? = nil,
        rightBarButtonAction: Selector? = nil,
        showBackButton: Bool = true
    ) {
        // Clear existing navigation bar customizations
        navigationItem.titleView = nil
        navigationItem.rightBarButtonItem = nil
        navigationItem.leftBarButtonItems = nil

        // Add the logo view
        let logoImageView = UIImageView(image: logoImage)
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.translatesAutoresizingMaskIntoConstraints = false

        let logoContainerView = UIView()
        logoContainerView.addSubview(logoImageView)
        logoContainerView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: logoContainerView.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: logoContainerView.centerYAnchor),
            logoImageView.heightAnchor.constraint(equalToConstant: 25),
            logoImageView.widthAnchor.constraint(equalToConstant: 100)
        ])

        navigationItem.titleView = logoContainerView

        // Add the right bar button
        if let rightImage = rightBarButtonImage {
            let rightButton = UIButton(type: .custom)
            rightButton.setImage(rightImage.withRenderingMode(.alwaysOriginal), for: .normal)
            rightButton.addTarget(self, action: rightBarButtonAction ?? #selector(defaultRightBarButtonTapped), for: .touchUpInside)
            rightButton.translatesAutoresizingMaskIntoConstraints = false
            rightButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
            rightButton.heightAnchor.constraint(equalToConstant: 40).isActive = true

            let rightBarButtonItem = UIBarButtonItem(customView: rightButton)
            navigationItem.rightBarButtonItem = rightBarButtonItem
        }

        // Show or hide the back button
        navigationItem.hidesBackButton = !showBackButton
    }

    @objc private func defaultRightBarButtonTapped() {
        print("Right bar button tapped!")
    }
}

extension UIViewController {
    func setupCustomNavigationBar2(
        withLogo logoImage: UIImage?,
        rightBarButtonImage: UIImage? = nil,
        rightBarButtonAction: Selector? = nil,
        showBackButton: Bool = true
    ) {
        // Clear existing navigation bar customizations
        navigationItem.titleView = nil
        navigationItem.rightBarButtonItem = nil
        navigationItem.leftBarButtonItems = nil

        // Create the logo view
        let logoImageView = UIImageView(image: logoImage)
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.translatesAutoresizingMaskIntoConstraints = false

        let logoContainerView = UIView()
        logoContainerView.addSubview(logoImageView)
        logoContainerView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            logoImageView.leadingAnchor.constraint(equalTo: logoContainerView.leadingAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: logoContainerView.centerYAnchor),
            logoImageView.heightAnchor.constraint(equalToConstant: 25),
            logoImageView.widthAnchor.constraint(equalToConstant: 100)
        ])

        let logoBarButtonItem = UIBarButtonItem(customView: logoContainerView)
        navigationItem.leftBarButtonItem = logoBarButtonItem

        // Add the right bar button
        if let rightImage = rightBarButtonImage {
            let rightButton = UIButton(type: .custom)
            rightButton.setImage(rightImage.withRenderingMode(.alwaysOriginal), for: .normal)
            rightButton.addTarget(self, action: rightBarButtonAction ?? #selector(defaultRightBarButtonTapped2), for: .touchUpInside)
            rightButton.translatesAutoresizingMaskIntoConstraints = false
            rightButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
            rightButton.heightAnchor.constraint(equalToConstant: 40).isActive = true

            let rightBarButtonItem = UIBarButtonItem(customView: rightButton)
            navigationItem.rightBarButtonItem = rightBarButtonItem
        }

        // Show or hide the back button
        navigationItem.hidesBackButton = !showBackButton
    }

    @objc private func defaultRightBarButtonTapped2() {
        print("Right bar button tapped!")
    }
}





