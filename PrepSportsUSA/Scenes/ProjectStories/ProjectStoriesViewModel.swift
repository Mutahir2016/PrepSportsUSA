//
//  ProjectStoriesViewModel.swift
//  Lumen
//
//  Created by Syed Mutahir Pirzada on 17/06/2025.
//

import Foundation
import RxSwift
import RxRelay

class ProjectStoriesViewModel: BaseViewModel {
    
    var viewAllUseCase: ViewAllUseCase?
    let errorSubject = PublishSubject<Error>()
    let isLoadingRelay = BehaviorRelay<Bool>(value: false)

    private(set) var storiesArr = [Story]()

    weak var delegate: StoriesHomeViewModelDelegate?
    var totalRecords: Int = 0
    var currentPage: Int = 1
    var hasLoaded = false
    var isPaginationSet = false
    private var lock = NSRecursiveLock()
    let sessionExpiredRelay = PublishRelay<Void>() // Relay to notify session expiration
    var projectId = BehaviorRelay<Int>(value: 0)

    init(useCase: ViewAllUseCase = ViewAllUseCase(), projectId: Int) {
        super.init()

        self.viewAllUseCase = useCase
        self.projectId.accept(projectId)
    }
    
    func viewDidLoad() {
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
    
    /************************************************/
    
    func setFromDate(date: String) {
        if date != getFromDate() ?? "" {
            isPaginationSet = false
            totalRecords = 0
            currentPage = 1
            hasLoaded = false
            storiesArr.removeAll()
            delegate?.reloadTableData?()
        }
        
         UserDefaults.standard.set(date, forKey: StoriesHomeKey.fromDateRange.rawValue)
    }
    
    func setToDate(date: String) {
        if date != getToDate() ?? "" {
            isPaginationSet = false
            totalRecords = 0
            currentPage = 1
            hasLoaded = false
            storiesArr.removeAll()
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
        
        viewAllUseCase?
            .getStories(projectId: projectId.value,
                        fromDate: fromDate,
                        toDate: toDate,
                        page: currentPage,
                        pageSize: 10)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] stories in
                guard let self = self else { return }
                
                if let storiesObj = stories {
                    if !isPaginationSet {
                        isPaginationSet = true
                        self.totalRecords = storiesObj.meta.pagination.records
                        self.currentPage = storiesObj.meta.pagination.current
                    }
                    self.isLoadingRelay.accept(false)
                    
                    if storiesObj.data .isEmpty {
                        hasLoaded = true
                    } else {
                        self.storiesArr.append(contentsOf: storiesObj.data)
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
