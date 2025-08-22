//
//  StoriesRouter.swift
//  Lumen
//
//  Created by Syed Mutahir Pirzada on 24/01/2025.
//
import UIKit

class StoriesRouter: BaseRouter {
    weak var viewController: StoriesViewController!
    
    init(_ viewController: StoriesViewController!) {
        self.viewController = viewController
    }
    
    func routeToTopLoc(_ storyId: String) {
        guard let topLocVC = UIViewController.getViewControllerFrom(name: .topLoc) as? TopLocViewController else { return }
        topLocVC.viewModel = TopLocViewModel(storyId: storyId)
        
        navigate(from: viewController, to: topLocVC)
    }
    
    func routeToTopOrg(_ storyId: String) {
        guard let topLocVC = UIViewController.getViewControllerFrom(name: .topOrg) as? TopOrgViewController else { return }
        topLocVC.viewModel = TopOrgViewModel(storyId: storyId)
        
        navigate(from: viewController, to: topLocVC)
    }
    
    func routeToOutboundClicks(_ storyId: String) {
        guard let outboundVC = UIViewController.getViewControllerFrom(name: .outbound) as? OutboundViewController else { return }
        outboundVC.viewModel = OutboundViewModel(storyId: storyId)
        
        navigate(from: viewController, to: outboundVC)
    }
    
    func routeToMaps(_ storyId: String) {
        guard let outboundVC = UIViewController.getViewControllerFrom(name: .map) as? MapViewController else { return }
        outboundVC.viewModel = MapViewModel(storyId: storyId)
        
        navigate(from: viewController, to: outboundVC)
    }
}
