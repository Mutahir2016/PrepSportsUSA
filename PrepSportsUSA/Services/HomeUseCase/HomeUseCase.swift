//
//  HomeUseCase.swift
//  Lumen
//
//  Created by Syed Mutahir Pirzada on 28/01/2025.
//

import RxSwift

protocol HomeUseCaseProtocol {
    func getStoryWatcher(userId: Int, fromDate: String, toDate: String) -> Observable<HomeStoryModel?>
    func getPageView(userId: Int, pageNumber: Int, fromDate: String, toDate: String) -> Observable<PageViewModel?>
    func getStoryGeography(userId: Int, pageNumber: Int,  fromDate: String, toDate: String) -> Observable<GeographyModel?>
    func getStoryOrganizations(userId: Int, pageNumber: Int,  fromDate: String, toDate: String) -> Observable<TopOrganizationsModel?>
    func getStoryOutlink(userId: Int, pageNumber: Int,  fromDate: String, toDate: String) -> Observable<HomeOutLinkModel?>
}

class HomeUseCase {
    let disposeBag: DisposeBag = DisposeBag()
    private var service: HomeUseCaseProtocol
    
    init(service: HomeService = HomeService() ) {
        self.service = service
    }
    
    func getStoryGeography(userId: Int, pageNumber: Int,  fromDate: String, toDate: String)-> Observable<(GeographyModel?)> {
        return service.getStoryGeography(userId: userId, pageNumber: pageNumber, fromDate: fromDate, toDate: toDate)
    }
    
    func getStoryOutlink(userId: Int, pageNumber: Int,  fromDate: String, toDate: String)-> Observable<(HomeOutLinkModel?)> {
        return service.getStoryOutlink(userId: userId, pageNumber: pageNumber, fromDate: fromDate, toDate: toDate)
    }
    
    func getStoryOrganizations(userId: Int, pageNumber: Int,  fromDate: String, toDate: String)-> Observable<(TopOrganizationsModel?)> {
        return service.getStoryOrganizations(userId: userId, pageNumber: pageNumber, fromDate: fromDate, toDate: toDate)
    }
    
    func getStory(userId: Int, fromDate: String, toDate: String)-> Observable<(HomeStoryModel?)> {
        return service.getStoryWatcher(userId: userId, fromDate: fromDate, toDate: toDate)
    }
    
    func getPageView(userId: Int, pageNumber: Int, fromDate: String, toDate: String) -> Observable<PageViewModel?> {
        return service.getPageView(userId: userId, pageNumber: pageNumber, fromDate: fromDate, toDate: toDate)
    }
}
