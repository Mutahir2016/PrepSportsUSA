//
//  StoryHomeUseCase.swift
//  Lumen
//
//  Created by Syed Mutahir Pirzada on 12/01/2025.
//

import Foundation
import RxSwift

protocol StoryHomeUseCaseProtocol {
    func getStories(fromDate: String, toDate: String, page: Int, pageSize: Int, sortBy: String?) -> Observable<StoryHomeModel?>
}

class StoryHomeUseCase {
    let disposeBag: DisposeBag = DisposeBag()
    private var service: StoryHomeUseCaseProtocol
    
    init(service: StoryHomeService = StoryHomeService() ) {
        self.service = service
    }
    
    func fetchStories(fromDate: String, toDate: String, page: Int, pageSize: Int, sortBy: String?) -> Observable<(StoryHomeModel?)> {
        return service.getStories(fromDate: fromDate,
                                  toDate: toDate,
                                  page: page,
                                  pageSize: pageSize, sortBy: sortBy)
    }
}
