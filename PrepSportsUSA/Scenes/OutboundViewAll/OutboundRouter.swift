//
//  OutboundRouter.swift
//  Lumen
//
//  Created by Syed Mutahir Pirzada on 11/02/2025.
//

class OutboundRouter: BaseRouter {
    
    weak var viewController: OutboundViewController!
    
    init(_ viewController: OutboundViewController!) {
        self.viewController = viewController
    }
}
