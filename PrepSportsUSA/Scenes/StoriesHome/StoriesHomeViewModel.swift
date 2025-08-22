//
//  StoriesHomeViewModel.swift
//  Lumen
//
//  Created by Syed Mutahir Pirzada on 11/01/2025.
//

import Foundation
import RxSwift
import RxRelay

@objc protocol StoriesHomeViewModelDelegate: AnyObject {
    @objc optional func reloadTableData()
    func setDateOnUI(toDate: String, fromDate: String)
    func setRangeSelection(toDate: Date, fromDate: Date)
}

class StoriesHomeViewModel: BaseViewModel {
    
    var storyHomeUsecase: StoryHomeUseCase?
    let errorSubject = PublishSubject<Error>()
    let isLoadingRelay = BehaviorRelay<Bool>(value: false)

    private(set) var stories = [Story]()

    weak var delegate: StoriesHomeViewModelDelegate?
    var totalRecords: Int = 0
    var currentPage: Int = 1
    var hasLoaded = false
    var isPaginationSet = false
    private var lock = NSRecursiveLock()
    let sessionExpiredRelay = PublishRelay<Void>() // Relay to notify session expiration
    var sortOptionsArr = [String]()
    var sortBy: String?
    
    init(useCase: StoryHomeUseCase = StoryHomeUseCase()) {
        super.init()

        self.storyHomeUsecase = useCase
    }
    
    func viewDidLoad() {
        self.resetAllValues()

        if let fromDate = getFromDate(), let toDate = getToDate() {
            delegate?.setDateOnUI(toDate: toDate, fromDate: fromDate)
            delegate?.setRangeSelection(toDate: toDate.toDate(format: "yyyy-MM-dd") ?? Date(), fromDate: fromDate.toDate(format: "yyyy-MM-dd") ?? Date())
            fetchStories(fromDate: fromDate, toDate: toDate)
        } else {
            let calendar = Calendar.current

            let toDate = calendar.date(byAdding: .day, value: -1, to: Date())!
            let fromDate = calendar.date(byAdding: .day, value: -30, to: Date())!
            
            delegate?.setRangeSelection(toDate: toDate, fromDate: fromDate)
            
            delegate?.setDateOnUI(toDate: toDate.formatted(template: "MMM dd, yyyy"), fromDate: fromDate.formatted(template: "MMM dd, yyyy"))
            fetchStories(fromDate: fromDate.formatted(template: "yyyy-MM-dd"), toDate: toDate.formatted(template: "yyyy-MM-dd"))
        }
    }
    
    private func resetAllValues() {
        hasLoaded = false
        self.stories.removeAll()
        self.isPaginationSet = false
        self.currentPage = 1
        self.totalRecords = 0
    }
    
    /************************************************/
    
    func setFromDate(date: String) {
        if date != getFromDate() ?? "" {
            resetAllValues()
            delegate?.reloadTableData?()
        }
        
         UserDefaults.standard.set(date, forKey: StoriesHomeKey.fromDateRange.rawValue)
    }
    
    func setToDate(date: String) {
        if date != getToDate() ?? "" {
            resetAllValues()
            delegate?.reloadTableData?()
        }
        
        UserDefaults.standard.set(date, forKey: StoriesHomeKey.toDateRange.rawValue)
    }
    /************************************************/
    
    func fetchStories(fromDate: String, toDate: String) {
        if hasLoaded {
            return
        }
        isLoadingRelay.accept(true)
        
        // Lock the function to prevent multiple requests from being made simultaneously
        lock.lock()
        defer { lock.unlock() }
        
        storyHomeUsecase?
            .fetchStories(fromDate: fromDate, toDate: toDate, page: currentPage, pageSize: 10, sortBy: sortBy)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] storyHomeModel in
                guard let self = self else { return }
                
                if let storiesObj = storyHomeModel {
                    if !isPaginationSet {
                        isPaginationSet = true
                        self.totalRecords = storiesObj.meta.pagination.records
                        self.currentPage = storiesObj.meta.pagination.current
                    }
                    self.isLoadingRelay.accept(false)
                    
                    if storiesObj.data .isEmpty {
                        hasLoaded = true
                    } else {
                        self.stories.append(contentsOf: storiesObj.data)
                    }
                    self.delegate?.reloadTableData?()
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
