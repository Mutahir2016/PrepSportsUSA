//
//  ViewAllUseCase.swift
//  Lumen
//
//  Created by Syed Mutahir Pirzada on 12/01/2025.
//

import Foundation
import RxSwift

protocol ViewAllUseCaseProtocol {
    func getStories(fromDate: String, toDate: String, page: Int, pageSize: Int) -> Observable<StoryHomeModel?>
    func getStoryGeography(storyId: String, pageNumber: Int,  fromDate: String, toDate: String, isComingFromNetwork: Bool)-> Observable<(GeographyModel?)>
    func getStoryOutlink(storyId: String, pageNumber: Int,  fromDate: String, toDate: String, isComingFromNetwork: Bool) -> Observable<OutlinkModel?>
    func getStoryOrganizations(storyId: String, pageNumber: Int,  fromDate: String, toDate: String, isComingFromNetwork: Bool) -> Observable<TopOrganizationsModel?>
    func getStoryGeography(storyId: String,fromDate: String, toDate: String, isComingFromNetwork: Bool) -> Observable<GeographyModel?>
    
    func getStories(projectId: Int, fromDate: String, toDate: String, page: Int, pageSize: Int) -> Observable<StoryHomeModel?>

}

class ViewAllUseCase {
    let disposeBag: DisposeBag = DisposeBag()
    private var service: ViewAllUseCaseProtocol
    
    init(service: ViewAllService = ViewAllService() ) {
        self.service = service
    }
    
    func fetchStories(fromDate: String, toDate: String, page: Int, pageSize: Int) -> Observable<(StoryHomeModel?)> {
        return service.getStories(fromDate: fromDate,
                                  toDate: toDate,
                                  page: page,
                                  pageSize: pageSize)
    }
    
    func getStoryGeography(storyId: String, pageNumber: Int,  fromDate: String, toDate: String, isComingFromNetwork: Bool = false)-> Observable<(GeographyModel?)> {
        return service.getStoryGeography(storyId: storyId,
                                         pageNumber: pageNumber,
                                         fromDate: fromDate,
                                         toDate: toDate,
                                         isComingFromNetwork: isComingFromNetwork)
    }
    
    func getStoryOutlink(storyId: String, pageNumber: Int,  fromDate: String, toDate: String, isComingFromNetwork: Bool = false)-> Observable<(OutlinkModel?)> {
        return service.getStoryOutlink(storyId: storyId, pageNumber: pageNumber, fromDate: fromDate, toDate: toDate, isComingFromNetwork: isComingFromNetwork)
    }
    
    func getStoryOrganizations(storyId: String, pageNumber: Int,  fromDate: String, toDate: String, isComingFromNetwork: Bool = false)-> Observable<(TopOrganizationsModel?)> {
        return service.getStoryOrganizations(storyId: storyId, pageNumber: pageNumber, fromDate: fromDate, toDate: toDate, isComingFromNetwork: isComingFromNetwork)
    }
    
    func getStoryGeography(storyId: String,fromDate: String, toDate: String, isComingFromNetwork:Bool = false) -> Observable<GeographyModel?> {
        return service.getStoryGeography(storyId: storyId,
                                         fromDate: fromDate,
                                         toDate: toDate,
                                         isComingFromNetwork: isComingFromNetwork)
    }
    
    func getStories(projectId: Int, fromDate: String, toDate: String, page: Int, pageSize: Int) -> Observable<StoryHomeModel?> {
        return service.getStories(projectId: projectId, fromDate: fromDate, toDate: toDate, page: page, pageSize: pageSize)
    }
}
