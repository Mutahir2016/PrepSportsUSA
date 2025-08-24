//
//  AddSportsBriefRouter.swift
//  PrepSportsUSA
//
//  Created by PrepSportsUSA on 25/08/2025.
//

import UIKit

class AddSportsBriefRouter: BaseRouter {
    weak var viewController: AddSportsBriefViewController!
    
    init(_ viewController: AddSportsBriefViewController) {
        self.viewController = viewController
    }
    
    // MARK: - Navigation Routes
    func dismiss() {
        viewController.navigationController?.popViewController(animated: true)
    }
    
    func dismissToRoot() {
        viewController.navigationController?.popToRootViewController(animated: true)
    }
    
    func showSuccessAndDismiss() {
        let alert = UIAlertController(title: "Success", message: "Sports brief submitted successfully!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            self.dismiss()
        }))
        viewController.present(alert, animated: true)
    }
    
    func navigateToSelectSchoolOrganization() {
        let storyboard = UIStoryboard(name: "SelectSchoolOrganization", bundle: nil)
        if let selectSchoolVC = storyboard.instantiateViewController(withIdentifier: "SelectSchoolOrganizationViewController") as? SelectSchoolOrganizationViewController {
            let navController = UINavigationController(rootViewController: selectSchoolVC)
            navController.modalPresentationStyle = .pageSheet
            viewController.present(navController, animated: true)
        }
    }
    
    func logoutAndNavigateToSignIn() {
        // Clear user session
        RKStorage.shared.clearLoggedInPreferences()
        
        // Navigate to sign in screen
        guard let signInVC = UIViewController.getViewControllerFor(name: .signIn) as? SigninViewController else { return }
        let navController = UINavigationController(rootViewController: signInVC)
        
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate,
           let window = sceneDelegate.window {
            window.rootViewController = navController
            window.makeKeyAndVisible()
        }
    }
}
