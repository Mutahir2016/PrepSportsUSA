//
//  StoriesViewModel.swift
//  Lumen
//
//  Created by Syed Mutahir Pirzada on 19/01/2025.
//
import Foundation
import RxRelay

class StoriesViewModel: BaseViewModel {
    
    var storyId = BehaviorRelay<String>(value: "")
    var storyUseCase: StoryUseCase?
    var indexingRelay = BehaviorRelay<IndexingData?>(value: nil)
    var geographyRelay = BehaviorRelay<[GeographyData]?>(value: nil)
    var outLinksRelay = BehaviorRelay<OutlinkModel?>(value: nil)
    var topOrganizationsRelay = BehaviorRelay<TopOrganizationsModel?>(value: nil)
    var storyRelay = BehaviorRelay<StoryModelData?>(value: nil)
    var pageViewRelay = BehaviorRelay<[PageViewData]?>(value: nil)
    let sessionExpiredRelay = PublishRelay<Void>() // Relay to notify session expiration

    let isLoadingRelay = BehaviorRelay<Bool>(value: false)
    let shouldShowShimmer = BehaviorRelay<Bool>(value: true)
    let shouldPopulatePageViews = BehaviorRelay<Bool>(value: false)

    let dispatchAPIGroup = DispatchGroup()
    var nCount = 0
    var isAuthFailed = false
    weak var delegate: StoriesHomeViewModelDelegate?

    init(useCase: StoryUseCase = StoryUseCase(), storyId: String, delegate: StoriesHomeViewModelDelegate? = nil) {
        super.init()
        self.storyUseCase = useCase
        // Observe changes to storyId
        observeStoryId()
        self.delegate = delegate
        // Assign initial value to storyId
        self.storyId.accept(storyId)
        
        // Notify when both tasks are completed
        
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
        }
        
        dispatchAPIGroup.notify(queue: .main) {
            print("All API calls are completed and total count is \(self.nCount)")
            self.shouldShowShimmer.accept(false)
            self.shouldPopulatePageViews.accept(true)
         }
    }
    
    func setFromDate(date: String) {
        if date != getFromDate() ?? "" {
//            delegate?.reloadTableData?()
        }
        
         UserDefaults.standard.set(date, forKey: StoriesHomeKey.fromDateRange.rawValue)
    }
    
    func setToDate(date: String) {
        if date != getToDate() ?? "" {
//            delegate?.reloadTableData?()
        }
        
        UserDefaults.standard.set(date, forKey: StoriesHomeKey.toDateRange.rawValue)
    }
    
    func fetchStories(fromDate: String, toDate: String) {
        let storyId = storyId.value
        self.getStory(storyId)
        self.getPageViews(storyId)
        self.fetchTopOrganizations(storyId)
        self.fetchGeography(storyId)
        self.fetchOutlinks(storyId)
        self.fetchIndexing(storyId)
    }
    
    func observeStoryId() {
        storyId
            .skip(1)
            .subscribe(onNext: { [weak self] storyId in
                self?.getStory(storyId)
                self?.getPageViews(storyId)
                self?.fetchTopOrganizations(storyId)
                self?.fetchGeography(storyId)
                self?.fetchOutlinks(storyId)
                self?.fetchIndexing(storyId)
            })
            .disposed(by: disposeBag)
    }
    
    private func getStory(_ storyId: String) {
        if isAuthFailed {
            return
        }
        dispatchAPIGroup.enter()
        nCount += 1
        isLoadingRelay.accept(true)
        
        let toDate = UserDefaults.standard.value(forKey: StoriesHomeKey.toDateRange.rawValue) as? String
        let fromDate = UserDefaults.standard.value(forKey: StoriesHomeKey.fromDateRange.rawValue) as? String
        storyUseCase?.getStory(storyId: storyId,fromDate: fromDate ?? "", toDate: toDate ?? "")
            .subscribe(onNext: { [weak self] response in
                guard let self = self else { return }
                if let data = response?.data {
                    self.storyRelay.accept(data)
                }
                dispatchAPIGroup.leave()
                isLoadingRelay.accept(false)
            },
                       onError: { [weak self] error in
                guard let self = self else { return }
                // Handle the error
                isLoadingRelay.accept(false)
                dispatchAPIGroup.leave()
                if let customError = error as? CustomError, customError == .sessionExpired {
                    self.isAuthFailed = true
                    self.sessionExpiredRelay.accept(()) // Emit session expired event
                } else {
                    print("API Error: \(error.localizedDescription)")
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func fetchIndexing(_ storyId: String) {
        if isAuthFailed {
            return
        }
        let toDate = UserDefaults.standard.value(forKey: StoriesHomeKey.toDateRange.rawValue) as? String
        let fromDate = UserDefaults.standard.value(forKey: StoriesHomeKey.fromDateRange.rawValue) as? String
        storyUseCase?.getStoryIndexing(storyId: storyId, fromDate: fromDate ?? "", toDate: toDate ?? "")
            .subscribe(onNext: { [weak self] response in
                guard let self = self else { return }
                if let data = response?.data {
                    self.indexingRelay.accept(data)
                }
            },
                       onError: { [weak self] error in
                guard let self = self else { return }
                // Handle the error
                isLoadingRelay.accept(false)
                if let customError = error as? CustomError, customError == .sessionExpired {
                    self.isAuthFailed = true
                    self.sessionExpiredRelay.accept(()) // Emit session expired event
                } else {
                    print("API Error: \(error.localizedDescription)")
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func fetchGeography(_ storyId: String) {
        if isAuthFailed {
            return
        }
        isLoadingRelay.accept(true)
        
        let toDate = UserDefaults.standard.value(forKey: StoriesHomeKey.toDateRange.rawValue) as? String
        let fromDate = UserDefaults.standard.value(forKey: StoriesHomeKey.fromDateRange.rawValue) as? String
        storyUseCase?.getStoryGeography(storyId: storyId, pageNumber: 1,fromDate: fromDate ?? "", toDate: toDate ?? "")
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
                    self.isAuthFailed = true
                    self.sessionExpiredRelay.accept(()) // Emit session expired event
                } else {
                    print("API Error: \(error.localizedDescription)")
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func fetchOutlinks(_ storyId: String) {
        if isAuthFailed {
            return
        }
        isLoadingRelay.accept(true)
        dispatchAPIGroup.enter()
        nCount += 1

        let toDate = UserDefaults.standard.value(forKey: StoriesHomeKey.toDateRange.rawValue) as? String
        let fromDate = UserDefaults.standard.value(forKey: StoriesHomeKey.fromDateRange.rawValue) as? String
        storyUseCase?.getStoryOutlink(storyId: storyId, pageNumber: 1,fromDate: fromDate ?? "", toDate: toDate ?? "")
            .subscribe(onNext: { [weak self] response in
                guard let self = self else { return }
                if let data = response {
                    self.outLinksRelay.accept(data)
                }
                dispatchAPIGroup.leave()
                isLoadingRelay.accept(false)
            },
                       onError: { [weak self] error in
                guard let self = self else { return }
                // Handle the error
                isLoadingRelay.accept(false)
                dispatchAPIGroup.leave()
                if let customError = error as? CustomError, customError == .sessionExpired {
                    self.isAuthFailed = true
                    self.sessionExpiredRelay.accept(()) // Emit session expired event
                } else {
                    print("API Error: \(error.localizedDescription)")
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func fetchTopOrganizations(_ storyId: String) {
        if isAuthFailed {
            return
        }
        isLoadingRelay.accept(true)
        dispatchAPIGroup.enter()
        nCount += 1

        let toDate = UserDefaults.standard.value(forKey: StoriesHomeKey.toDateRange.rawValue) as? String
        let fromDate = UserDefaults.standard.value(forKey: StoriesHomeKey.fromDateRange.rawValue) as? String
        storyUseCase?.getStoryOrganizations(storyId: storyId, pageNumber: 1,fromDate: fromDate ?? "", toDate: toDate ?? "")
            .subscribe(onNext: { [weak self] response in
                guard let self = self else { return }
                if let _ = response?.data {
                    self.topOrganizationsRelay.accept(response)
                }
                dispatchAPIGroup.leave()
                isLoadingRelay.accept(false)
            },
                       onError: { [weak self] error in
                guard let self = self else { return }
                // Handle the error
                dispatchAPIGroup.leave()
                isLoadingRelay.accept(false)
                if let customError = error as? CustomError, customError == .sessionExpired {
                    self.isAuthFailed = true
                    self.sessionExpiredRelay.accept(()) // Emit session expired event
                } else {
                    print("API Error: \(error.localizedDescription)")
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func getPageViews(_ storyId: String) {
        if isAuthFailed {
            return
        }
        isLoadingRelay.accept(true)
        
        let toDate = UserDefaults.standard.value(forKey: StoriesHomeKey.toDateRange.rawValue) as? String
        let fromDate = UserDefaults.standard.value(forKey: StoriesHomeKey.fromDateRange.rawValue) as? String
        storyUseCase?.getPageView(storyId: storyId, pageNumber: 1,fromDate: fromDate ?? "", toDate: toDate ?? "")
            .subscribe(onNext: { [weak self] response in
                guard let self = self else { return }
                if let data = response?.data {
                    self.pageViewRelay.accept(data)
                }
                isLoadingRelay.accept(false)
            },
                       onError: { [weak self] error in
                guard let self = self else { return }
                // Handle the error
                isLoadingRelay.accept(false)
                if let customError = error as? CustomError, customError == .sessionExpired {
                    self.isAuthFailed = true
                    self.sessionExpiredRelay.accept(()) // Emit session expired event
                } else {
                    print("API Error: \(error.localizedDescription)")
                }
            })
            .disposed(by: disposeBag)
    }
}
