//
//  CustomTabbarViewModel.swift
//  Lumen
//
//  Created by Syed Mutahir Pirzada on 01/01/2025.
//

import Foundation
import Alamofire

protocol CustomTabbarViewModelDelegate: AnyObject {
    func unreadMessageUpdated(hasUnread: Bool)
    func networkStatus(isReachable: Bool)
}

class CustomTabbarViewModel: BaseViewModel {
  
    weak var delegate: CustomTabbarViewModelDelegate?
    
    private let networkReachability = NetworkReachabilityManager()
    
    func viewDidLoad() {
        observeNetwork()
    }
    
    func viewWillAppear() {
        loadUnreadMessage()
    }
    
    func viewDidActive() {
        loadUnreadMessage()
    }
    
    deinit {
        networkReachability?.stopListening()
        print("CustomTabbarViewModel released ♻️")
    }
    
    private func loadUnreadMessage() {
        
        guard RKStorage.shared.tokenExists() else { return }
        
    }
    
    private func observeNetwork() {
        networkReachability?.startListening { [weak self] _ in
            guard let networkReachability = self?.networkReachability else { return }
            self?.delegate?.networkStatus(isReachable: networkReachability.isReachable)
        }
    }
}
