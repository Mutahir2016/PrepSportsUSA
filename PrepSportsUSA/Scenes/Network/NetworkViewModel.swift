//
//  NetworkViewModel.swift
//  Lumen
//
//  Created by Syed Mutahir Pirzada on 25/06/2025.
//

import Foundation
import RxSwift
import RxRelay


class NetworkViewModel: BaseViewModel {
    weak var delegate: StoriesHomeViewModelDelegate?
    
    var networkUseCase: NetworkUseCase?
    let errorSubject = PublishSubject<Error>()
    let sessionExpiredRelay = PublishRelay<Void>() // Relay to notify session expiration
    var networkRelay = BehaviorRelay<[NetworkDatum]?>(value: nil)
    var projectRelay = BehaviorRelay<[NetworkDatum]?>(value: nil)
    var pageViewRelay = BehaviorRelay<[PageViewData]?>(value: nil)
    var pageViewMetaRelay = BehaviorRelay<PageViewMeta?>(value: nil)
    var geographyRelay = BehaviorRelay<[GeographyData]?>(value: nil)
    var topOrganizationsRelay = BehaviorRelay<TopOrganizationsModel?>(value: nil)
    let shouldPopulatePageViews = BehaviorRelay<Bool>(value: false)
    var storyRelay = BehaviorRelay<[Story]?>(value: nil)
    var outLinksRelay = BehaviorRelay<NetworkOutLinkModel?>(value: nil)
    let shouldShowShimmer = BehaviorRelay<Bool>(value: true)
    var indexingRelay = BehaviorRelay<IndexingData?>(value: nil)
    let errorMessageRelay = PublishRelay<String>()
    private var isSessionValid = true

    var selectedNetwork: NetworkDatum?
    var selectedProject: NetworkDatum?

    let isLoadingRelay = BehaviorRelay<Bool>(value: false)
    private var lock = NSRecursiveLock()
    let dispatchAPIGroup = DispatchGroup()
    var nCount = 0
    var hasLoadedAPICalls: Bool = false
    
    init(useCase: NetworkUseCase = NetworkUseCase()) {
        super.init()
        self.networkUseCase = useCase
    }
    
    
    func loadInitialData() {
        getUserProfileAndThenLoadAll()
    }
    
    private func getUserProfileAndThenLoadAll() {
        guard isSessionValid else {
            print("⛔️ Session is invalid. Skipping user profile API call.")
            return
        }

        isLoadingRelay.accept(true)
        
        let userId = RKStorage.shared.getSignIn()?.user_id ?? 0
        networkUseCase?
            .getUserProfile(userId: userId)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] response in
                guard let self = self else { return }

                self.isLoadingRelay.accept(false)

                // ✅ Now safe to load other APIs
                self.loadNetworksAndProjects()

            }, onError: { [weak self] error in
                guard let self = self else { return }
                self.isLoadingRelay.accept(false)

                if let refreshError = error as? RefreshTokenError,
                   case let .service(innerError) = refreshError,
                   let customError = innerError as? CustomError,
                   customError == .sessionExpired {
                    self.isSessionValid = false
                    self.sessionExpiredRelay.accept(())
                    print("🚫 Session expired. Stopping further API calls.")
                } else {
                    self.errorMessageRelay.accept(error.localizedDescription)
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func loadNetworksAndProjects() {
        getNetworkData()
        
        if let selectedProject = self.selectedProject {
            projectRelay.accept([selectedProject])
            reloadProject(selectedProject)
        }
    }
    
    func viewDidLoad() {
        setDate()
        selectedNetwork = RKStorage.shared.getNetwokData(forKey: StoriesHomeKey.network.rawValue, as: NetworkDatum.self)
        selectedProject = RKStorage.shared.getNetwokData(forKey: StoriesHomeKey.project.rawValue, as: NetworkDatum.self)

        if let selectedNetwork = selectedNetwork {
            networkRelay.accept([selectedNetwork])
        }

        loadInitialData() // 🔥 Only this starts APIs
    }
    
    private func observeAPICompletion() {
        dispatchAPIGroup.notify(queue: .main) {
            print("✅ All API calls completed and nCount = \(self.nCount)")
            self.shouldShowShimmer.accept(false)
            self.shouldPopulatePageViews.accept(true)
            self.nCount = 0
        }
    }
    
    func setDate() {
        if let fromDate = getFromDate(), let toDate = getToDate() {
            delegate?.setDateOnUI(toDate: toDate, fromDate: fromDate)
            delegate?.setRangeSelection(toDate: toDate.toDate(format: "yyyy-MM-dd") ?? Date(), fromDate: fromDate.toDate(format: "yyyy-MM-dd") ?? Date())
        } else {
            let calendar = Calendar.current

            let toDate = calendar.date(byAdding: .day, value: -1, to: Date())!
            let fromDate = calendar.date(byAdding: .day, value: -30, to: Date())!
            
            UserDefaults.standard.set(toDate.formatted(template: "yyyy-MM-dd"), forKey: StoriesHomeKey.toDateRange.rawValue)
            UserDefaults.standard.set(fromDate.formatted(template: "yyyy-MM-dd"), forKey: StoriesHomeKey.fromDateRange.rawValue)
            
            delegate?.setRangeSelection(toDate: toDate, fromDate: fromDate)
            
            delegate?.setDateOnUI(toDate: toDate.formatted(template: "MMM dd, yyyy"), fromDate: fromDate.formatted(template: "MMM dd, yyyy"))
        }
    }
    
    /************************************************/
    
    func setFromDate(date: String) {
        if date != getFromDate() ?? "" {
            delegate?.reloadTableData?()
        }
        
         UserDefaults.standard.set(date, forKey: StoriesHomeKey.fromDateRange.rawValue)
    }
    
    func setToDate(date: String) {
        if date != getToDate() ?? "" {
            delegate?.reloadTableData?()
        }
        
        UserDefaults.standard.set(date, forKey: StoriesHomeKey.toDateRange.rawValue)
    }
    
    /************************************************/

    private func getNetworkData() {
        
        // Lock the function to prevent multiple requests from being made simultaneously
        lock.lock()
        defer { lock.unlock() }
        
        networkUseCase?
            .getNetworks()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] networkModel in
                guard let self = self else { return }
                
                if let networkData = networkModel {
                    self.isLoadingRelay.accept(false)
                    self.networkRelay.accept(networkData.data)
                    if let firstItem = networkData.data.first {
                        self.getProjectData(firstItem.customAttributes.id)
                    }
                    
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
    
    private func getProjectData(_ networkId: Int) {
        
        // Lock the function to prevent multiple requests from being made simultaneously
        lock.lock()
        defer { lock.unlock() }
        
        networkUseCase?
            .getProject(networkId)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] networkModel in
                guard let self = self else { return }
                
                if let projectData = networkModel {
                    self.isLoadingRelay.accept(false)
                    self.projectRelay.accept(projectData.data)
                    if let firstItem = projectData.data.first {
                        if hasLoadedAPICalls { return }
                        self.getStory(firstItem.customAttributes.id)
                        self.getPageViews(firstItem.customAttributes.id)
                        self.fetchGeography(firstItem.customAttributes.id)
                        self.fetchTopOrganizations(firstItem.customAttributes.id)
                        self.fetchOutlinks(firstItem.customAttributes.id)
//                        self.fetchIndexing(firstItem.customAttributes.id)
                        
                        self.observeAPICompletion()
                    }
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

extension NetworkViewModel {
    func reloadProject(_ network: NetworkDatum) {
        self.selectedProject  = network
        let projectId = network.customAttributes.id
        
        self.getStory(projectId)
        self.fetchGeography(projectId)
        self.fetchTopOrganizations(projectId)
        self.getPageViews(projectId)
        self.fetchOutlinks(projectId)
//        self.fetchIndexing(projectId)
        
        self.hasLoadedAPICalls = true
        self.observeAPICompletion()
    }
    
}

extension NetworkViewModel {
    
    private func getStory(_ projectId: Int) {
        isLoadingRelay.accept(true)
        
        let toDate = UserDefaults.standard.value(forKey: StoriesHomeKey.toDateRange.rawValue) as? String
        let fromDate = UserDefaults.standard.value(forKey: StoriesHomeKey.fromDateRange.rawValue) as? String
        networkUseCase?.getStory(projectId: projectId,fromDate: fromDate ?? "", toDate: toDate ?? "")
            .subscribe(onNext: { [weak self] response in
                guard let self = self else { return }
                if let data = response?.data {
                    let limitedData = Array(data.prefix(5)) // ✅ Limit to max 5
                    self.storyRelay.accept(limitedData)
                }
                
                    self.isLoadingRelay.accept(false)

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
    
    private func getPageViews(_ projectId: Int) {
        isLoadingRelay.accept(true)
        dispatchAPIGroup.enter()
        nCount += 1
        
        let toDate = UserDefaults.standard.value(forKey: StoriesHomeKey.toDateRange.rawValue) as? String
        let fromDate = UserDefaults.standard.value(forKey: StoriesHomeKey.fromDateRange.rawValue) as? String
        networkUseCase?.getPageView(projectId: projectId, pageNumber: 1,fromDate: fromDate ?? "", toDate: toDate ?? "")
            .subscribe(onNext: { [weak self] response in
                guard let self = self else { return }
                if let data = response?.data {
                    self.pageViewRelay.accept(data)
                    self.pageViewMetaRelay.accept(response?.meta)
                }
                isLoadingRelay.accept(false)
                dispatchAPIGroup.leave()
            },
                       onError: { [weak self] error in
                guard let self = self else { return }
                self.pageViewRelay.accept(nil)
                // Handle the error
                print("Resend Auth API Error: \(error.localizedDescription)")
                isLoadingRelay.accept(false)
                dispatchAPIGroup.leave()
                // Optionally show the error to the user or update UI
                //                    self.forgotPasswordMessage.accept("An error occurred. Please try again.")
            })
            .disposed(by: disposeBag)
    }
    
    private func fetchOutlinks(_ projectId: Int) {
        isLoadingRelay.accept(true)
        dispatchAPIGroup.enter()
        nCount += 1

        let toDate = UserDefaults.standard.value(forKey: StoriesHomeKey.toDateRange.rawValue) as? String
        let fromDate = UserDefaults.standard.value(forKey: StoriesHomeKey.fromDateRange.rawValue) as? String
        networkUseCase?.getStoryOutlink(projectId: projectId, pageNumber: 1,fromDate: fromDate ?? "", toDate: toDate ?? "")
            .subscribe(onNext: { [weak self] response in
                guard let self = self else { return }
                
                if let fullResponse = response {
                    // 🔽 Sort data by clicks descending
                    let sortedData = fullResponse.data.sorted {
                        ($0.attributes.nClicks ?? 0) > ($1.attributes.nClicks ?? 0)
                    }
                    
                    let trimmedData = Array(sortedData.prefix(5))
                    
                    let trimmedResponse = NetworkOutLinkModel(
                        data: trimmedData,
                        meta: fullResponse.meta,
                        links: fullResponse.links
                    )
                    self.outLinksRelay.accept(trimmedResponse)
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
    
    private func fetchGeography(_ projectId: Int) {
        isLoadingRelay.accept(true)
        
        let toDate = UserDefaults.standard.value(forKey: StoriesHomeKey.toDateRange.rawValue) as? String
        let fromDate = UserDefaults.standard.value(forKey: StoriesHomeKey.fromDateRange.rawValue) as? String
        networkUseCase?.getStoryGeography(projectId: projectId, pageNumber: 1,fromDate: fromDate ?? "", toDate: toDate ?? "")
            .subscribe(onNext: { [weak self] response in
                guard let self = self else { return }
                if let data = response?.data {
                    self.geographyRelay.accept(data)
                }
                isLoadingRelay.accept(false)
            }, onError: { [weak self] error in
                guard let self = self else { return }
                // Handle the error
                print("Resend Auth API Error: \(error.localizedDescription)")
                isLoadingRelay.accept(false)
                // Optionally show the error to the user or update UI
                //                    self.forgotPasswordMessage.accept("An error occurred. Please try again.")
            })
            .disposed(by: disposeBag)
    }
    
    private func fetchTopOrganizations(_ projectId: Int) {
        isLoadingRelay.accept(true)
        dispatchAPIGroup.enter()
        nCount += 1
        
        let toDate = UserDefaults.standard.value(forKey: StoriesHomeKey.toDateRange.rawValue) as? String
        let fromDate = UserDefaults.standard.value(forKey: StoriesHomeKey.fromDateRange.rawValue) as? String
        networkUseCase?.getStoryOrganizations(projectId: projectId, pageNumber: 1,fromDate: fromDate ?? "", toDate: toDate ?? "")
            .subscribe(onNext: { [weak self] response in
                guard let self = self else { return }
                if let response = response {
                    let trimmedData = Array(response.data.prefix(5))
                    let trimmedResponse = TopOrganizationsModel(
                        data: trimmedData,
                        meta: response.meta,
                        links: response.links
                    )
                    self.topOrganizationsRelay.accept(trimmedResponse)
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
    
    private func fetchIndexing(_ projectId: Int) {
        
        let toDate = UserDefaults.standard.value(forKey: StoriesHomeKey.toDateRange.rawValue) as? String
        let fromDate = UserDefaults.standard.value(forKey: StoriesHomeKey.fromDateRange.rawValue) as? String
        networkUseCase?.getStoryIndexing(projectId: projectId, fromDate: fromDate ?? "", toDate: toDate ?? "")
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
                    self.sessionExpiredRelay.accept(()) // Emit session expired event
                } else {
                    print("API Error: \(error.localizedDescription)")
                }
            })
            .disposed(by: disposeBag)
    }
}
