//
//  ProjectSheetViewModel.swift
//  Lumen
//
//  Created by Syed Mutahir Pirzada on 27/04/2025.
//

import RxSwift
import RxCocoa
import UIKit
import Foundation

class ProjectSheetViewModel: BaseViewModel {
    
    var useCase: NetworkUseCase?
    var projectRelay = BehaviorRelay<[NetworkDatum]?>(value: nil)
    weak var delegate: NetworkSheetViewModelDelegate?
    private var lock = NSRecursiveLock()
    let isLoadingRelay = BehaviorRelay<Bool>(value: false)
    let errorSubject = PublishSubject<Error>()
    let sessionExpiredRelay = PublishRelay<Void>() // Relay to notify session expiration
    
    init(useCase: NetworkUseCase = NetworkUseCase(), projectList: [NetworkDatum]?, delegate: StoriesHomeViewModelDelegate? = nil, networkId: Int?) {
        super.init()
        self.useCase = useCase
        self.projectRelay.accept(projectList)
        if networkId != nil {
            getProjectData(networkId ?? 0)
        }
        
    }
    
    private func getProjectData(_ networkId: Int) {
        
        // Lock the function to prevent multiple requests from being made simultaneously
        lock.lock()
        defer { lock.unlock() }
        
        guard let useCase = useCase else { return }
        
        useCase
            .getProject(networkId)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] networkModel in
                guard let self = self else { return }
                
                if let projectData = networkModel {
                    self.isLoadingRelay.accept(false)
                    self.projectRelay.accept(projectData.data)
                }
            }, onError: { [weak self] error in
                self?.isLoadingRelay.accept(false)
                self?.errorSubject.onNext(error)
                if let customError = error as? CustomError, customError == .sessionExpired {
                    self?.sessionExpiredRelay.accept(()) // Emit session expired event
                } else {
                    print("API Error: \(error.localizedDescription)")
                }
            })
            .disposed(by: disposeBag)
    }
}
