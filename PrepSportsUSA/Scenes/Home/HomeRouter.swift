//
//  HomeRouter.swift
//  Lumen
//
//  Created by Syed Mutahir Pirzada on 11/01/2025.
//

import UIKit

class HomeRouter: BaseRouter {
    weak var viewController: HomeViewController!
    
    init(_ viewController: HomeViewController) {
        self.viewController = viewController
    }
    
    func routeToAuthVerification() {
        guard let destination = UIViewController.getViewControllerFrom(name: .authVerification) as? AuthVerificationViewController else { return }
        navigate(from: viewController, to: destination)
    }
    
    func routeToMore() {
        guard let destination = UIViewController.getViewControllerFrom(name: .more) as? MoreViewController else { return }
        navigate(from: viewController, to: destination)
    }
}
