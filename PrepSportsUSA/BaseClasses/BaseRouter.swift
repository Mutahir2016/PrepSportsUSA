//
//  BaseRouter.swift
//  Lumen
//
//  Created by Syed Mutahir Pirzada on 24/12/2024.
//

import Foundation
import UIKit

class BaseRouter: NSObject {
  
  func navigate(from fromViewController: UIViewController,
                to toViewController: UIViewController,
                animate: Bool = true,
                hideTabbarLater: Bool = true) {
    fromViewController.navigationController?.pushViewController(toViewController,
                                                       animated: animate)
  }

  func didPopViewController(from fromViewController: BaseViewController, to toViewController: BaseViewController, animate: Bool = true) {
    fromViewController.modalPresentationStyle = .overCurrentContext
    fromViewController.navigationController?.present(toViewController, animated: animate)
  }
    
    func openExternalLink(with url: URL?) {
        guard let externalUrl = url else { return }
        if UIApplication.shared.canOpenURL(externalUrl) {
            UIApplication.shared.open(externalUrl, options: [:],
                                      completionHandler: nil)
        } else {
            print(" open app error , no call back URL after request login failed")
        }
    }
  
  func routeToSettings() {
      if let appSettings = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(appSettings) {
          UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
      }
  }
    
    func popViewController(from viewController: UIViewController) {
        guard let navigationController = viewController.navigationController else { return }
        navigationController.popViewController(animated: true)
    }
    
    func popToRoot(from viewController: UIViewController) {
            guard let navigationController = viewController.navigationController else { return }
            navigationController.popToRootViewController(animated: true)
        }
    
    func logoutAndNavigateToSignIn(from viewController: UIViewController) {
        let email = UserDefaults.standard.string(forKey: UserCredentialKeys.email.rawValue)
        let password = UserDefaults.standard.string(forKey: UserCredentialKeys.password.rawValue)
        let biometricStatus = UserDefaults.standard.bool(forKey: RKStorageAccount.biometricEnabled.rawValue)
        let biometricUser = UserDefaults.standard.string(forKey: RKStorageAccount.biometricEnabledUser.rawValue) // 👈

        if let appDomain = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: appDomain)
        }
        UserDefaults.standard.synchronize()

        guard let signinViewController = UIViewController.getViewControllerFrom(name: .signIn) as? SigninViewController else { return }

        UserDefaults.standard.set(email, forKey: UserCredentialKeys.email.rawValue)
        UserDefaults.standard.set(password, forKey: UserCredentialKeys.password.rawValue)
        UserDefaults.standard.set(biometricStatus, forKey: RKStorageAccount.biometricEnabled.rawValue)
        UserDefaults.standard.set(biometricUser, forKey: RKStorageAccount.biometricEnabledUser.rawValue) // 👈 restore

        // Find the current active UIWindowScene
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            print("Unable to access the current window scene!")
            return
        }
        
        // Set the sign-in screen as the root view controller
        window.rootViewController = UINavigationController(rootViewController: signinViewController)
        window.makeKeyAndVisible()
        
        // Optionally, animate the transition
        UIView.transition(with: window, duration: 0.5, options: .transitionFlipFromRight, animations: nil, completion: nil)
    }
    
    func routeToMore(from viewController: UIViewController) {
        guard let destination = UIViewController.getViewControllerFrom(name: .more) as? MoreViewController else { return }
        navigate(from: viewController, to: destination)
    }
    
    func routeToStoriesHome(from viewController: UIViewController) {
        guard let destination = UIViewController.getViewControllerFrom(name: .storiesHome) as? StoriesHomeViewController else { return }
        navigate(from: viewController, to: destination)
    }
    
    func routeToNetwork(from viewController: UIViewController) {
        guard let destination = UIViewController.getViewControllerFrom(name: .network) as? NetworkViewController else { return }
        navigate(from: viewController, to: destination)
    }
    
    func routeToTopLoc(from viewController: UIViewController) {
        guard let destination = UIViewController.getViewControllerFrom(name: .topLoc) as? TopLocViewController else { return }
        navigate(from: viewController, to: destination)
    }
    
    func routeToMaps(from viewController: UIViewController, for  idd: String, isComingFromNetwork: Bool = false) {
        guard let outboundVC = UIViewController.getViewControllerFrom(name: .map) as? MapViewController else { return }
        outboundVC.viewModel = MapViewModel(storyId: idd, isComingFromNetwork: isComingFromNetwork)
        
        navigate(from: viewController, to: outboundVC)
    }
    
    func routeToTopLoc(from viewController: UIViewController, for  idd: String, isComingFromNetwork: Bool = false) {
        guard let topLocVC = UIViewController.getViewControllerFrom(name: .topLoc) as? TopLocViewController else { return }
        topLocVC.viewModel = TopLocViewModel(storyId: idd, isComingFromNetwork: isComingFromNetwork)
        
        navigate(from: viewController, to: topLocVC)
    }
    
    func routeToTopOrg(from viewController: UIViewController, for  idd: String, isComingFromNetwork: Bool = false) {
        guard let topLocVC = UIViewController.getViewControllerFrom(name: .topOrg) as? TopOrgViewController else { return }
        topLocVC.viewModel = TopOrgViewModel(storyId: idd, isComingFromNetwork: isComingFromNetwork)
        
        navigate(from: viewController, to: topLocVC)
    }
    
    func routeToOutboundClicks(from viewController: UIViewController, for  idd: String, isComingFromNetwork: Bool = false) {
        guard let outboundVC = UIViewController.getViewControllerFrom(name: .outbound) as? OutboundViewController else { return }
        outboundVC.viewModel = OutboundViewModel(storyId: idd, isComingFromNetwork: isComingFromNetwork)
        
        navigate(from: viewController, to: outboundVC)
    }
    
    func routeToStories(from viewController: UIViewController, for  idd: String, isComingFromNetwork: Bool = false) {
        guard let outboundVC = UIViewController.getViewControllerFrom(name: .outbound) as? OutboundViewController else { return }
        outboundVC.viewModel = OutboundViewModel(storyId: idd, isComingFromNetwork: isComingFromNetwork)
        
        navigate(from: viewController, to: outboundVC)
    }
    
    func routeToProjectStories(from viewController: UIViewController, for  projectId: Int) {
        guard let projectStoriesVC = UIViewController.getViewControllerFrom(name: .projectStories) as? ProjectStoriesViewController else { return }
        projectStoriesVC.viewModel = ProjectStoriesViewModel(projectId: projectId)
        
        navigate(from: viewController, to: projectStoriesVC)
    }
  
    func routeToSearch(from viewController: UIViewController) {
        guard let destination = UIViewController.getViewControllerFrom(name: .search) as? SearchViewController else { return }
        navigate(from: viewController, to: destination)
    }
}

protocol ViewRouter {
    var viewController: UIViewController! { get }
}

protocol NavigationViewRouter: ViewRouter {
    var navigationController: UINavigationController { get }
}
