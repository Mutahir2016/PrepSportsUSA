//
//  StoryUseCase.swift
//  Lumen
//
//  Created by Syed Mutahir Pirzada on 18/01/2025.
//

import RxSwift

protocol StoryUseCaseProtocol {
    func getStoryIndexing(storyId: String, fromDate: String, toDate: String) -> Observable<IndexingModel?>
    func getStoryGeography(storyId: String, pageNumber: Int,  fromDate: String, toDate: String) -> Observable<GeographyModel?>
    func getStoryOutlink(storyId: String, pageNumber: Int,  fromDate: String, toDate: String) -> Observable<OutlinkModel?>
    func getStoryOrganizations(storyId: String, pageNumber: Int,  fromDate: String, toDate: String) -> Observable<TopOrganizationsModel?>
    func getStory(storyId: String, fromDate: String, toDate: String) -> Observable<StoryModel?>
    func getPageView(storyId: String, pageNumber: Int, fromDate: String, toDate: String) -> Observable<PageViewModel?>
}

class StoryUseCase {
    let disposeBag: DisposeBag = DisposeBag()
    private var service: StoryUseCaseProtocol
    
    init(service: StoryService = StoryService() ) {
        self.service = service
    }
    
    func getStoryIndexing(storyId: String, fromDate: String, toDate: String) -> Observable<(IndexingModel?)> {
        return service.getStoryIndexing(storyId: storyId, fromDate: fromDate, toDate: toDate)
    }
    
    func getStoryGeography(storyId: String, pageNumber: Int,  fromDate: String, toDate: String)-> Observable<(GeographyModel?)> {
        return service.getStoryGeography(storyId: storyId, pageNumber: pageNumber, fromDate: fromDate, toDate: toDate)
    }
    
    func getStoryOutlink(storyId: String, pageNumber: Int,  fromDate: String, toDate: String)-> Observable<(OutlinkModel?)> {
        return service.getStoryOutlink(storyId: storyId, pageNumber: pageNumber, fromDate: fromDate, toDate: toDate)
    }
    
    func getStoryOrganizations(storyId: String, pageNumber: Int,  fromDate: String, toDate: String)-> Observable<(TopOrganizationsModel?)> {
        return service.getStoryOrganizations(storyId: storyId, pageNumber: pageNumber, fromDate: fromDate, toDate: toDate)
    }
    
    func getStory(storyId: String, fromDate: String, toDate: String)-> Observable<(StoryModel?)> {
        return service.getStory(storyId: storyId, fromDate: fromDate, toDate: toDate)
    }
    
    func getPageView(storyId: String, pageNumber: Int, fromDate: String, toDate: String) -> Observable<PageViewModel?> {
        return service.getPageView(storyId: storyId, pageNumber: pageNumber, fromDate: fromDate, toDate: toDate)
    }
}
