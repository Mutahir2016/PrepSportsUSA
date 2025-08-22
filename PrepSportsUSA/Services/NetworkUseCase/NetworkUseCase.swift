//
//  NetworkUseCase.swift
//  Lumen
//
//  Created by Syed Mutahir Pirzada on 27/04/2025.
//

import RxSwift

protocol NetworkUseCaseProtocol {
    func getNetworks() -> Observable<NetworkModel?>
    func getProject(_ networkId: Int) -> Observable<NetworkModel?>
    func getStoryWatcher(projectId: Int, fromDate: String, toDate: String) -> Observable<StoryHomeModel?>
    func getStoryGeography(projectId: Int, pageNumber: Int,  fromDate: String, toDate: String) -> Observable<GeographyModel?>
    func getStoryOrganizations(projectId: Int, pageNumber: Int,  fromDate: String, toDate: String) -> Observable<TopOrganizationsModel?>
    func getStoryOutlink(projectId: Int, pageNumber: Int, fromDate: String, toDate: String) -> Observable<NetworkOutLinkModel?>
    func getPageView(projectId: Int, pageNumber: Int, fromDate: String, toDate: String) -> Observable<PageViewModel?>
    func getStoryIndexing(projectId: Int, fromDate: String, toDate: String) -> Observable<IndexingModel?>
    func getUser(userId: Int) -> Observable<UserProfile>
}

class NetworkUseCase {
    let disposeBag: DisposeBag = DisposeBag()
    private var service: NetworkUseCaseProtocol
    
    init(service: NetworkServices = NetworkServices() ) {
        self.service = service
    }
    
    func getNetworks()-> Observable<(NetworkModel?)> {
        return service.getNetworks()
    }
    
    func getProject(_ networkId: Int)-> Observable<(NetworkModel?)> {
        return service.getProject(networkId)
    }
    
    func getStoryGeography(projectId: Int, pageNumber: Int,  fromDate: String, toDate: String)-> Observable<(GeographyModel?)> {
        return service.getStoryGeography(projectId: projectId, pageNumber: pageNumber, fromDate: fromDate, toDate: toDate)
    }
    
    func getStoryOrganizations(projectId: Int, pageNumber: Int,  fromDate: String, toDate: String)-> Observable<(TopOrganizationsModel?)> {
        return service.getStoryOrganizations(projectId: projectId, pageNumber: pageNumber, fromDate: fromDate, toDate: toDate)
    }
    
    func getStory(projectId: Int, fromDate: String, toDate: String)-> Observable<(StoryHomeModel?)> {
        return service.getStoryWatcher(projectId: projectId, fromDate: fromDate, toDate: toDate)
    }
    
    func getStoryOutlink(projectId: Int, pageNumber: Int,  fromDate: String, toDate: String)-> Observable<(NetworkOutLinkModel?)> {
        return service.getStoryOutlink(projectId: projectId, pageNumber: pageNumber, fromDate: fromDate, toDate: toDate)
    }
    
    func getPageView(projectId: Int, pageNumber: Int, fromDate: String, toDate: String) -> Observable<PageViewModel?> {
        return service.getPageView(projectId: projectId, pageNumber: pageNumber, fromDate: fromDate, toDate: toDate)
    }
    
    func getStoryIndexing(projectId: Int, fromDate: String, toDate: String) -> Observable<(IndexingModel?)> {
        return service.getStoryIndexing(projectId: projectId, fromDate: fromDate, toDate: toDate)
    }
    
    func getUserProfile(userId: Int) -> Observable<UserProfile> {
        return service.getUser(userId: userId)
    }
}
