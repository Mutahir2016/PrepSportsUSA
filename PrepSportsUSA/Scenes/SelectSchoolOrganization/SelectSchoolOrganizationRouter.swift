//
//  SelectSchoolOrganizationRouter.swift
//  PrepSportsUSA
//
//  Created by PrepSportsUSA on 25/08/2025.
//

import UIKit
import Foundation

class SelectSchoolOrganizationRouter: BaseRouter {
    
    weak var viewController: SelectSchoolOrganizationViewController?
    
    init(_ viewController: SelectSchoolOrganizationViewController) {
        self.viewController = viewController
    }
    
    func dismiss() {
        viewController?.dismiss(animated: true)
    }
    
    func dismissWithSelection(_ school: SchoolOrganizationData) {
        // Pass the selected school back to the presenting view controller
        if let navController = viewController?.presentingViewController as? UINavigationController,
           let addBriefVC = navController.viewControllers.first(where: { $0 is AddSportsBriefViewController }) as? AddSportsBriefViewController {
            addBriefVC.didSelectSchoolOrganization(school)
        } else if let addBriefVC = viewController?.presentingViewController as? AddSportsBriefViewController {
            addBriefVC.didSelectSchoolOrganization(school)
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
