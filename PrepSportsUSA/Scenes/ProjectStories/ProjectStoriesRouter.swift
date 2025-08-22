//
//  ProjectStoriesRouter.swift
//  Lumen
//
//  Created by Syed Mutahir Pirzada on 18/06/2025.
//

import Foundation
import UIKit

class ProjectStoriesRouter: BaseRouter {
    
    weak var viewController: ProjectStoriesViewController!
    
    init(_ viewController: ProjectStoriesViewController) {
        self.viewController = viewController
    }
    
    func routeToStoryDetails(_ storyId: String) {
        guard let storyDetailVC = UIViewController.getViewControllerFrom(name: .stories) as? StoriesViewController else { return }
        storyDetailVC.viewModel = StoriesViewModel(storyId: storyId, delegate: storyDetailVC)
        navigate(from: viewController, to: storyDetailVC)
    }
}
