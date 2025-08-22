//
//  SigninRouter.swift
//  Lumen
//
//  Created by Syed Mutahir Pirzada on 24/12/2024.
//

import Foundation
import UIKit

class SigninRouter: BaseRouter {
    
    weak var viewController: SigninViewController!
    
    init(_ viewController: SigninViewController) {
        self.viewController = viewController
    }
    
    func routeToForgetPassword(_ email: String?) {
        guard let forgetPasswordVC = UIViewController.getViewControllerFrom(name: .forgotPassword) as? ForgotPasswordViewController else { return }
        forgetPasswordVC.viewModel = ForgotPasswordViewModel(email: email)
        
        navigate(from: viewController, to: forgetPasswordVC)
    }
    
    func routeToAuthVerification(email: String, and response: signInData) {
        guard let authVC = UIViewController.getViewControllerFrom(name: .authVerification) as? AuthVerificationViewController else { return }
        authVC.viewModel = AuthVerificationViewModel(email: email, signInData: response, router: AuthVerificationRouter(authVC))
        
        navigate(from: viewController, to: authVC)
    }
    
    func routeToStories() {
        guard let destination = UIViewController.getViewControllerFrom(name: .storiesHome) as? StoriesHomeViewController else { return }
        navigate(from: viewController, to: destination)
    }
    
    func routeToNetwork() {
        guard let destination = UIViewController.getViewControllerFrom(name: .network) as? NetworkViewController else { return }
        navigate(from: viewController, to: destination)
    }
    
    func routeToHome() {
        guard let destination = UIViewController.getViewControllerFrom(name: .home) as? HomeViewController else { return }
        navigate(from: viewController, to: destination)
    }
}

