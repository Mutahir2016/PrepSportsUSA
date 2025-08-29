//
//  SportsBriefDetailRouter.swift
//  PrepSportsUSA
//
//  Created by Cascade on 30/08/2025.
//

import UIKit

final class SportsBriefDetailRouter: BaseRouter {
    weak var viewController: SportsBriefDetailViewController!
    
    init(_ viewController: SportsBriefDetailViewController) {
        self.viewController = viewController
    }
    
    // Convenience to match VC call without passing `from:`
    func logoutAndNavigateToSignIn() {
        super.logoutAndNavigateToSignIn(from: viewController)
    }
}
