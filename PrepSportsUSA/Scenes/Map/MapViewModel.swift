//
//  MapViewModel.swift
//  Lumen
//
//  Created by Syed Mutahir Pirzada on 13/02/2025.
//

import UIKit
import RxRelay
import RxSwift
import RxCocoa

class MapViewModel: BaseViewModel {
    
    var storyId = BehaviorRelay<String>(value: "")
    var viewAllUseCase: ViewAllUseCase?
    var geographyRelay = BehaviorRelay<[GeographyData]?>(value: nil)
    let isLoadingRelay = BehaviorRelay<Bool>(value: false)
    let sessionExpiredRelay = PublishRelay<Void>() // Relay to notify session expiration
    weak var delegate: StoriesHomeViewModelDelegate?
    var isComingFromNetwork: Bool = false
    
    init(useCase: ViewAllUseCase = ViewAllUseCase(), storyId: String, isComingFromNetwork: Bool = false) {
        super.init()
        
        self.viewAllUseCase = useCase
        self.isComingFromNetwork = isComingFromNetwork
        self.storyId.accept(storyId)
    }
    
    func viewDidLoad() {
        if let fromDate = getFromDate(), let toDate = getToDate() {
            delegate?.setDateOnUI(toDate: toDate, fromDate: fromDate)
            delegate?.setRangeSelection(toDate: toDate.toDate(format: "yyyy-MM-dd") ?? Date(), fromDate: fromDate.toDate(format: "yyyy-MM-dd") ?? Date())
            
            fetchGeography(fromDate: fromDate, toDate: toDate, isComingFromNetwork: self.isComingFromNetwork)
        } else {
            let calendar = Calendar.current

            let toDate = calendar.date(byAdding: .day, value: -1, to: Date())!
            let fromDate = calendar.date(byAdding: .day, value: -30, to: Date())!
            
            delegate?.setRangeSelection(toDate: toDate, fromDate: fromDate)
            
            delegate?.setDateOnUI(toDate: toDate.formatted(template: "MMM dd, yyyy"), fromDate: fromDate.formatted(template: "MMM dd, yyyy"))
            fetchGeography(fromDate: fromDate.formatted(template: "yyyy-MM-dd"), toDate: toDate.formatted(template: "yyyy-MM-dd"), isComingFromNetwork: self.isComingFromNetwork)
        }
    }
    
    func setFromDate(date: String) {
        UserDefaults.standard.set(date, forKey: StoriesHomeKey.fromDateRange.rawValue)
    }
    
    func setToDate(date: String) {
        UserDefaults.standard.set(date, forKey: StoriesHomeKey.toDateRange.rawValue)
    }
    
    func fetchGeography(fromDate: String, toDate: String, isComingFromNetwork: Bool = false) {

        isLoadingRelay.accept(true)
        viewAllUseCase?.getStoryGeography(storyId: storyId.value,fromDate: fromDate, toDate: toDate, isComingFromNetwork: isComingFromNetwork)
            .subscribe(onNext: { [weak self] response in
                guard let self = self else { return }
                if let data = response?.data {
                    self.geographyRelay.accept(data)
                }
                isLoadingRelay.accept(false)
            },
                       onError: { [weak self] error in
                guard let self = self else { return }
                // Handle the error
                isLoadingRelay.accept(false)
                
                if let customError = error as? CustomError, customError == .sessionExpired {
                    self.sessionExpiredRelay.accept(()) // Emit session expired event
                } else {
                    print("API Error: \(error.localizedDescription)")
                }
            })
            .disposed(by: disposeBag)
    }
}
