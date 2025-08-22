//
//  MoreRouter.swift
//  Lumen
//
//  Created by Syed Mutahir Pirzada on 21/01/2025.
//
import UIKit
import Foundation

class MoreRouter: BaseRouter {
    
    weak var viewController: MoreViewController!
    
    init(_ viewController: MoreViewController) {
        self.viewController = viewController
    }
}
