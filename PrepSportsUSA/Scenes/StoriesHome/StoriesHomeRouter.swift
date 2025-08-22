//
//  StoriesHomeRouter.swift
//  Lumen
//
//  Created by Syed Mutahir Pirzada on 11/01/2025.
//

import Foundation
import UIKit

class StoriesHomeRouter: BaseRouter {
    weak var viewController: StoriesHomeViewController!
    
    init(_ viewController: StoriesHomeViewController) {
        self.viewController = viewController
    }
    
    func routeToStoryDetails(_ storyId: String) {
        guard let storyDetailVC = UIViewController.getViewControllerFrom(name: .stories) as? StoriesViewController else { return }
        storyDetailVC.viewModel = StoriesViewModel(storyId: storyId, delegate: storyDetailVC)
        navigate(from: viewController, to: storyDetailVC)
    }
    
}
