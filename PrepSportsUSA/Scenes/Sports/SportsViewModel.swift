//
//  SportsViewModel.swift
//  PrepSportsUSA
//
//  Created by PrepSportsUSA on 22/08/2025.
//

import Foundation
import RxSwift
import RxRelay

@objc protocol SportsViewModelDelegate: AnyObject {
    @objc optional func reloadTableData()
}

class SportsViewModel: BaseViewModel {
    
    // MARK: - Properties
    var sportsUseCase: SportsUseCase?
    let isLoadingRelay = BehaviorRelay<Bool>(value: false)
    let sessionExpiredRelay = PublishRelay<Void>() // Relay to notify session expiration
    
    private(set) var prePitches = [PrePitchData]()
    
    weak var delegate: SportsViewModelDelegate?
    var totalRecords: Int = 0
    var currentPage: Int = 1
    var hasLoaded = false
    var isPaginationSet = false
    private var lock = NSRecursiveLock()
    
    init(useCase: SportsUseCase = SportsUseCase()) {
        super.init()
        self.sportsUseCase = useCase
    }
    
    func viewDidLoad() {
        self.resetAllValues()
        fetchPrePitches()
    }
    
    private func resetAllValues() {
        hasLoaded = false
        self.prePitches.removeAll()
        self.isPaginationSet = false
        self.currentPage = 1
        self.totalRecords = 0
    }
    
    func fetchPrePitches() {
        if hasLoaded {
            return
        }
        isLoadingRelay.accept(true)
        
        // Lock the function to prevent multiple requests from being made simultaneously
        lock.lock()
        defer { lock.unlock() }
        
        sportsUseCase?
            .fetchPrePitches(pageSize: 20, pageNumber: currentPage)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] prePitchesModel in
                guard let self = self else { return }
                
                if let prePitchesObj = prePitchesModel {
                    print("API Response - Data count: \(prePitchesObj.data.count)")
                    print("API Response - Meta: \(prePitchesObj.meta)")
                    
                    if !isPaginationSet {
                        isPaginationSet = true
                        self.totalRecords = prePitchesObj.meta.pagination?.records ?? 0
                        print("Total records set to: \(self.totalRecords)")
                    }
                    self.isLoadingRelay.accept(false)
                    
                    if prePitchesObj.data.isEmpty {
                        hasLoaded = true
                        print("No more data - hasLoaded set to true")
                    } else {
                        self.prePitches.append(contentsOf: prePitchesObj.data)
                        print("Current total items: \(self.prePitches.count)")
                        
                        // Check if we've loaded all available data
                        if self.prePitches.count >= self.totalRecords {
                            hasLoaded = true
                            print("All data loaded - hasLoaded set to true")
                        }
                    }
                    self.delegate?.reloadTableData?()
                } else {
                    print("API Response is nil")
                }
            }, onError: { [weak self] error in
                self?.isLoadingRelay.accept(false)
                if let customError = error as? CustomError, customError == .sessionExpired {
                    self?.sessionExpiredRelay.accept(()) // Emit session expired event
                } else {
                    print("API Error: \(error.localizedDescription)")
                }
            })
            .disposed(by: disposeBag)
    }
    
    func loadMoreData() {
        print("loadMoreData called - hasLoaded: \(hasLoaded), currentPage: \(currentPage)")
        if !hasLoaded {
            currentPage += 1
            print("Incrementing page to: \(currentPage)")
            fetchPrePitches()
        } else {
            print("Not loading more - hasLoaded is true")
        }
    }
    
    func refreshData() {
        resetAllValues()
        delegate?.reloadTableData?()
        fetchPrePitches()
    }
}
