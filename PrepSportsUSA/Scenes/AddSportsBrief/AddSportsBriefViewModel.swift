//
//  AddSportsBriefViewModel.swift
//  PrepSportsUSA
//
//  Created by PrepSportsUSA on 25/08/2025.
//

import Foundation
import RxSwift
import RxRelay

@objc protocol AddSportsBriefViewModelDelegate: AnyObject {
    @objc optional func briefSubmittedSuccessfully()
    @objc optional func briefSubmissionFailed(error: String)
}

class AddSportsBriefViewModel: BaseViewModel {
    
    // MARK: - Properties
    var addSportsBriefUseCase: AddSportsBriefUseCase?
    let isLoadingRelay = BehaviorRelay<Bool>(value: false)
    let sessionExpiredRelay = PublishRelay<Void>()
    let submissionSuccessRelay = PublishRelay<Void>()
    let submissionErrorRelay = PublishRelay<String>()
    
    weak var delegate: AddSportsBriefViewModelDelegate?
    
    init(useCase: AddSportsBriefUseCase = AddSportsBriefUseCase()) {
        super.init()
        self.addSportsBriefUseCase = useCase
    }
    
    func submitBrief(title: String, description: String) {
        isLoadingRelay.accept(true)
        
        addSportsBriefUseCase?
            .submitSportsBrief(title: title, description: description)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] success in
                guard let self = self else { return }
                self.isLoadingRelay.accept(false)
                
                if success {
                    print("Brief submitted successfully")
                    self.submissionSuccessRelay.accept(())
                    self.delegate?.briefSubmittedSuccessfully?()
                } else {
                    let errorMessage = "Failed to submit brief"
                    print("Brief submission failed: \(errorMessage)")
                    self.submissionErrorRelay.accept(errorMessage)
                    self.delegate?.briefSubmissionFailed?(error: errorMessage)
                }
            }, onError: { [weak self] error in
                guard let self = self else { return }
                self.isLoadingRelay.accept(false)
                
                if let customError = error as? CustomError, customError == .sessionExpired {
                    self.sessionExpiredRelay.accept(())
                } else {
                    let errorMessage = error.localizedDescription
                    print("API Error: \(errorMessage)")
                    self.submissionErrorRelay.accept(errorMessage)
                    self.delegate?.briefSubmissionFailed?(error: errorMessage)
                }
            })
            .disposed(by: disposeBag)
    }
    
    func validateInput(title: String?, description: String?) -> Bool {
        guard let title = title, !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              let description = description, !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              description != "Enter brief description..." else {
            return false
        }
        return true
    }
}
