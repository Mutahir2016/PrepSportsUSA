//
//  SelectGameRouter.swift
//  PrepSportsUSA
//
//  Created by PrepSportsUSA on 25/08/2025.
//

import UIKit
import Foundation

class SelectGameRouter: BaseRouter {
    
    weak var viewController: SelectGameViewController?
    
    init(_ viewController: SelectGameViewController) {
        self.viewController = viewController
    }
    
    func dismiss() {
        viewController?.dismiss(animated: true)
    }
    
    func dismissWithSelection(_ game: GameData) {
        // Pass the selected game back to the presenting view controller
        if let navController = viewController?.presentingViewController as? UINavigationController,
           let addBriefVC = navController.viewControllers.first(where: { $0 is AddSportsBriefViewController }) as? AddSportsBriefViewController {
            addBriefVC.didSelectGame(game)
        } else if let addBriefVC = viewController?.presentingViewController as? AddSportsBriefViewController {
            addBriefVC.didSelectGame(game)
        }
        dismiss()
    }
    
    func logoutAndNavigateToSignIn() {
        // Clear user session
        RKStorage.shared.clearLoggedInPreferences()
        
        // Navigate to sign in screen
        let storyboard = UIStoryboard(name: "SignIn", bundle: nil)
        if let signInVC = storyboard.instantiateViewController(withIdentifier: "SigninViewController") as? SigninViewController {
            let navController = UINavigationController(rootViewController: signInVC)
            navController.modalPresentationStyle = .fullScreen
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                window.rootViewController = navController
                window.makeKeyAndVisible()
            }
        }
    }
}
