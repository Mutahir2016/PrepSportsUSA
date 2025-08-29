//
//  SportsBriefDetailViewModel.swift
//  PrepSportsUSA
//
//  Created by Cascade on 30/08/2025.
//

import Foundation
import RxSwift
import RxRelay

final class SportsBriefDetailViewModel: BaseViewModel {
    private let useCase: SportsBriefDetailUseCase
    
    // Inputs
    let prePitchId: Int
    
    // Outputs
    let isLoadingRelay = BehaviorRelay<Bool>(value: false)
    let sessionExpiredRelay = PublishRelay<Void>()
    let detailRelay = BehaviorRelay<PrePitchData?>(value: nil)
    
    init(prePitchId: Int, useCase: SportsBriefDetailUseCase = SportsBriefDetailUseCase()) {
        self.prePitchId = prePitchId
        self.useCase = useCase
        super.init()
    }
    
    func fetch() {
        isLoadingRelay.accept(true)
        useCase.fetchPrePitchDetail(id: prePitchId)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] model in
                self?.isLoadingRelay.accept(false)
                self?.detailRelay.accept(model?.data)
            }, onError: { [weak self] error in
                self?.isLoadingRelay.accept(false)
                if let customError = error as? CustomError, customError == .sessionExpired {
                    self?.sessionExpiredRelay.accept(())
                } else {
                    print("Detail error: \(error.localizedDescription)")
                }
            })
            .disposed(by: disposeBag)
    }
}
