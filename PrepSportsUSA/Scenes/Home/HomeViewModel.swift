//
//  HomeViewModel.swift
//  Lumen
//
//  Created by Syed Mutahir Pirzada on 11/01/2025.
//

import Foundation
import RxSwift
import RxRelay

class HomeViewModel: BaseViewModel {
    
    var userId = BehaviorRelay<Int>(value: 0)
    var homeUseCase: HomeUseCase?
    var storyRelay = BehaviorRelay<HomeStoryModelData?>(value: nil)
    var pageViewRelay = BehaviorRelay<[PageViewData]?>(value: nil)
    var geographyRelay = BehaviorRelay<[GeographyData]?>(value: nil)
    var topOrganizationsRelay = BehaviorRelay<TopOrganizationsModel?>(value: nil)
    var outLinksRelay = BehaviorRelay<HomeOutLinkModel?>(value: nil)

    let isLoadingRelay = BehaviorRelay<Bool>(value: false)
    let shouldPopulatePageViews = BehaviorRelay<Bool>(value: false)

    let dispatchAPIGroup = DispatchGroup()
    var nCount = 0
    weak var delegate: StoriesHomeViewModelDelegate?

    init(useCase: HomeUseCase = HomeUseCase()) {
        super.init()
        self.homeUseCase = useCase
        
        // Notify when both tasks are completed
        dispatchAPIGroup.notify(queue: .main) {
            print("All API calls are completed and total count is \(self.nCount)")
            self.shouldPopulatePageViews.accept(true)
         }
    }
    
    func viewDidLoad() {
        if let fromDate = getFromDate(), let toDate = getToDate() {
            delegate?.setDateOnUI(toDate: toDate, fromDate: fromDate)

        } else {
            let calendar = Calendar.current

            let toDate = calendar.date(byAdding: .day, value: -1, to: Date())!
            let fromDate = calendar.date(byAdding: .day, value: -30, to: Date())!
            
            UserDefaults.standard.set(toDate.formatted(template: "yyyy-MM-dd"), forKey: StoriesHomeKey.toDateRange.rawValue)
            UserDefaults.standard.set(fromDate.formatted(template: "yyyy-MM-dd"), forKey: StoriesHomeKey.fromDateRange.rawValue)

            delegate?.setDateOnUI(toDate: toDate.formatted(template: "MMM dd, yyyy"), fromDate: fromDate.formatted(template: "MMM dd, yyyy"))
        }
        
        // Observe changes to UserId
        observeUserId()
        // Assign initial value to userId
        self.userId.accept(RKStorage.shared.getSignIn()?.user_id ?? 0)
    }
    
    /************************************************/
    
    func setFromDate(date: String) {
        if date != getFromDate() ?? "" {
            storyRelay.accept(nil)
            pageViewRelay.accept(nil)
            topOrganizationsRelay.accept(nil)
            geographyRelay.accept(nil)
            outLinksRelay.accept(nil)
        }
        
         UserDefaults.standard.set(date, forKey: StoriesHomeKey.fromDateRange.rawValue)
    }
    
    func setToDate(date: String) {
        if date != getToDate() ?? "" {
            storyRelay.accept(nil)
            pageViewRelay.accept(nil)
            topOrganizationsRelay.accept(nil)
            geographyRelay.accept(nil)
            outLinksRelay.accept(nil)
            self.userId.accept(RKStorage.shared.getSignIn()?.user_id ?? 0)
        }
        
        UserDefaults.standard.set(date, forKey: StoriesHomeKey.toDateRange.rawValue)
    }
    
    /************************************************/
    
    private func observeUserId() {
        userId
            .skip(1)
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] userId in
                self?.getStory(userId)
                self?.getPageViews(userId)
                self?.fetchTopOrganizations(userId)
                self?.fetchGeography(userId)
                self?.fetchOutlinks(userId)
            })
            .disposed(by: disposeBag)
    }
    
    private func getStory(_ userId: Int) {
        dispatchAPIGroup.enter()
        nCount += 1
        isLoadingRelay.accept(true)
        
        let toDate = UserDefaults.standard.value(forKey: StoriesHomeKey.toDateRange.rawValue) as? String
        let fromDate = UserDefaults.standard.value(forKey: StoriesHomeKey.fromDateRange.rawValue) as? String
        homeUseCase?.getStory(userId: userId,fromDate: fromDate ?? "", toDate: toDate ?? "")
            .subscribe(onNext: { [weak self] response in
                guard let self = self else { return }
                if let data = response?.data.first {
                    self.storyRelay.accept(data)
                }
                dispatchAPIGroup.leave()
                isLoadingRelay.accept(false)
            },
                       onError: { [weak self] error in
                guard let self = self else { return }
                // Handle the error
                print("Resend Auth API Error: \(error.localizedDescription)")
                isLoadingRelay.accept(false)
                // Optionally show the error to the user or update UI
                //                    self.forgotPasswordMessage.accept("An error occurred. Please try again.")
                dispatchAPIGroup.leave()
            })
            .disposed(by: disposeBag)
    }
    
    private func fetchGeography(_ userId: Int) {
        isLoadingRelay.accept(true)
        
        let toDate = UserDefaults.standard.value(forKey: StoriesHomeKey.toDateRange.rawValue) as? String
        let fromDate = UserDefaults.standard.value(forKey: StoriesHomeKey.fromDateRange.rawValue) as? String
        homeUseCase?.getStoryGeography(userId: userId, pageNumber: 1,fromDate: fromDate ?? "", toDate: toDate ?? "")
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
                print("Resend Auth API Error: \(error.localizedDescription)")
                isLoadingRelay.accept(false)
                // Optionally show the error to the user or update UI
                //                    self.forgotPasswordMessage.accept("An error occurred. Please try again.")
            })
            .disposed(by: disposeBag)
    }
    
    private func fetchOutlinks(_ userId: Int) {
        isLoadingRelay.accept(true)
        dispatchAPIGroup.enter()
        nCount += 1

        let toDate = UserDefaults.standard.value(forKey: StoriesHomeKey.toDateRange.rawValue) as? String
        let fromDate = UserDefaults.standard.value(forKey: StoriesHomeKey.fromDateRange.rawValue) as? String
        homeUseCase?.getStoryOutlink(userId: userId, pageNumber: 1,fromDate: fromDate ?? "", toDate: toDate ?? "")
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
                print("Resend Auth API Error: \(error.localizedDescription)")
                isLoadingRelay.accept(false)
                dispatchAPIGroup.leave()
                // Optionally show the error to the user or update UI
                //                    self.forgotPasswordMessage.accept("An error occurred. Please try again.")
            })
            .disposed(by: disposeBag)
    }
    
    private func fetchTopOrganizations(_ userId: Int) {
        isLoadingRelay.accept(true)
        dispatchAPIGroup.enter()
        nCount += 1

        let toDate = UserDefaults.standard.value(forKey: StoriesHomeKey.toDateRange.rawValue) as? String
        let fromDate = UserDefaults.standard.value(forKey: StoriesHomeKey.fromDateRange.rawValue) as? String
        homeUseCase?.getStoryOrganizations(userId: userId, pageNumber: 1,fromDate: fromDate ?? "", toDate: toDate ?? "")
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
                print("Resend Auth API Error: \(error.localizedDescription)")
                dispatchAPIGroup.leave()
                isLoadingRelay.accept(false)
                // Optionally show the error to the user or update UI
                //                    self.forgotPasswordMessage.accept("An error occurred. Please try again.")
            })
            .disposed(by: disposeBag)
    }
    
    private func getPageViews(_ userId: Int) {
        isLoadingRelay.accept(true)
        
        let toDate = UserDefaults.standard.value(forKey: StoriesHomeKey.toDateRange.rawValue) as? String
        let fromDate = UserDefaults.standard.value(forKey: StoriesHomeKey.fromDateRange.rawValue) as? String
        homeUseCase?.getPageView(userId: userId, pageNumber: 1,fromDate: fromDate ?? "", toDate: toDate ?? "")
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
                print("Resend Auth API Error: \(error.localizedDescription)")
                isLoadingRelay.accept(false)
                // Optionally show the error to the user or update UI
                //                    self.forgotPasswordMessage.accept("An error occurred. Please try again.")
            })
            .disposed(by: disposeBag)
    }
}
