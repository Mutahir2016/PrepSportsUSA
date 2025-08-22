//
//  NetworkRouter.swift
//  Lumen
//
//  Created by Syed Mutahir Pirzada on 23/04/2025.
//

import Foundation
import UIKit

class NetworkRouter: BaseRouter {
    weak var viewController: NetworkViewController!
    
    init(_ viewController: NetworkViewController) {
        self.viewController = viewController
    }
    
    func presentNetworkSheet(_ networkData: [NetworkDatum]?) {
        guard let networkSheetVC = UIViewController.getViewControllerFrom(name: .networkSheet) as? NetworkSheetViewController else { return }
        networkSheetVC.viewModel = NetworkSheetViewModel(networkList: networkData)
        networkSheetVC.viewModel.delegate = viewController  // <-- set delegate

        networkSheetVC.modalPresentationStyle = .automatic // or .pageSheet, .formSheet, etc.
        networkSheetVC.modalTransitionStyle = .coverVertical // (optional) animation style
        
        viewController.present(networkSheetVC, animated: true, completion: nil)
    }
    
    func presentProjectSheet(_ projectList: [NetworkDatum]?, networkId: Int?) {
        guard let projectSheetVC = UIViewController.getViewControllerFrom(name: .projectSheet) as? ProjectSheetViewController else { return }
        projectSheetVC.viewModel = ProjectSheetViewModel(projectList: projectList, networkId: networkId)
        projectSheetVC.viewModel.delegate = viewController  // <-- set delegate

        projectSheetVC.modalPresentationStyle = .automatic // or .pageSheet, .formSheet, etc.
        projectSheetVC.modalTransitionStyle = .coverVertical // (optional) animation style
        
        viewController.present(projectSheetVC, animated: true, completion: nil)
    }
    
    func routeToStoryDetails(_ storyId: String) {
        guard let storyDetailVC = UIViewController.getViewControllerFrom(name: .stories) as? StoriesViewController else { return }
        storyDetailVC.viewModel = StoriesViewModel(storyId: storyId, delegate: storyDetailVC)
        navigate(from: viewController, to: storyDetailVC)
    }
}
