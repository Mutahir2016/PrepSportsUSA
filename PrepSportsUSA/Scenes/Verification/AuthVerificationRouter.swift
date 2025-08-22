//
//  AuthVerificationRouter.swift
//  Lumen
//
//  Created by Syed Mutahir Pirzada on 25/12/2024.
//

import Foundation
import UIKit

class AuthVerificationRouter: BaseRouter {
 
    weak var viewController: AuthVerificationViewController!
    
    init(_ viewController: AuthVerificationViewController) {
        self.viewController = viewController
    }
    
    func routeToStories() {
        guard let destination = UIViewController.getViewControllerFrom(name: .storiesHome) as? StoriesHomeViewController else { return }
        navigate(from: viewController, to: destination)
    }
}
