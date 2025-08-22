//
//  SearchRouter.swift
//  Lumen
//
//  Created by Assistant on 24/12/2024.
//

import Foundation
import UIKit

class SearchRouter: BaseRouter {
    
    var viewController: SearchViewController!

    init(viewController: SearchViewController) {
        self.viewController = viewController
        super.init()
    }
    
    func routeToStoryDetails(_ storyId: String) {
        guard let storyDetailVC = UIViewController.getViewControllerFrom(name: .stories) as? StoriesViewController else { return }
        storyDetailVC.viewModel = StoriesViewModel(storyId: storyId, delegate: storyDetailVC)
        navigate(from: viewController, to: storyDetailVC)
    }
} 
