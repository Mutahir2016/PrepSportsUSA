//
//  TopOrgViewModel.swift
//  Lumen
//
//  Created by Syed Mutahir Pirzada on 11/02/2025.
//

import Foundation
import RxSwift
import RxRelay


class TopOrgViewModel: BaseViewModel {
    
    var viewAllUseCase: ViewAllUseCase?
    let errorSubject = PublishSubject<Error>()
    let isLoadingRelay = BehaviorRelay<Bool>(value: false)

    private(set) var topOrganizationArr = [TopOrganizationsData]()

    weak var delegate: StoriesHomeViewModelDelegate?
    var totalRecords: Int = 0
    var currentPage: Int = 1
    var hasLoaded = false
    var isPaginationSet = false
    private var lock = NSRecursiveLock()
    let sessionExpiredRelay = PublishRelay<Void>() // Relay to notify session expiration
    var storyId = BehaviorRelay<String>(value: "")
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
            fetchOrganizations(fromDate: fromDate, toDate: toDate)
        } else {
            let calendar = Calendar.current

            let toDate = calendar.date(byAdding: .day, value: -1, to: Date())!
            let fromDate = calendar.date(byAdding: .day, value: -30, to: Date())!
            
            delegate?.setRangeSelection(toDate: toDate, fromDate: fromDate)
            
            delegate?.setDateOnUI(toDate: toDate.formatted(template: "MMM dd, yyyy"), fromDate: fromDate.formatted(template: "MMM dd, yyyy"))
            fetchOrganizations(fromDate: fromDate.formatted(template: "yyyy-MM-dd"), toDate: toDate.formatted(template: "yyyy-MM-dd"))
        }
    }
    
    /************************************************/
    
    func setFromDate(date: String) {
        if date != getFromDate() ?? "" {
            isPaginationSet = false
            totalRecords = 0
            currentPage = 1
            hasLoaded = false
            topOrganizationArr.removeAll()
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
            topOrganizationArr.removeAll()
            delegate?.reloadTableData?()
        }
        
        UserDefaults.standard.set(date, forKey: StoriesHomeKey.toDateRange.rawValue)
    }
    /************************************************/
    
    func fetchOrganizations(fromDate: String, toDate: String) {
        if hasLoaded {
            return
        }
        isLoadingRelay.accept(true)
        
        // Lock the function to prevent multiple requests from being made simultaneously
        lock.lock()
        defer { lock.unlock() }
        
        viewAllUseCase?
            .getStoryOrganizations(storyId: storyId.value,
                                       pageNumber: currentPage,
                                       fromDate: fromDate,
                                       toDate: toDate,
                                   isComingFromNetwork: isComingFromNetwork)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] topLocModel in
                guard let self = self else { return }
                
                if let topLocObj = topLocModel {
                    if !isPaginationSet {
                        isPaginationSet = true
                        self.totalRecords = topLocObj.meta.pagination.records
                        self.currentPage = topLocObj.meta.pagination.current
                    }
                    self.isLoadingRelay.accept(false)
                    
                    if topLocObj.data .isEmpty {
                        hasLoaded = true
                    } else {
                        self.topOrganizationArr.append(contentsOf: topLocObj.data)
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
