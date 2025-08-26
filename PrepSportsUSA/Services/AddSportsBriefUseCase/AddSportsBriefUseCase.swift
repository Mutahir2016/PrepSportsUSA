//
//  AddSportsBriefUseCase.swift
//  PrepSportsUSA
//
//  Created by PrepSportsUSA on 25/08/2025.
//

import Foundation
import RxSwift

protocol AddSportsBriefUseCaseProtocol {
    func submitSportsBrief(title: String, description: String) -> Observable<Bool>
    func createPrePitchMediaLink(request: PrePitchMediaRequest) -> Observable<PrePitchMediaResponse>
    func uploadImageToPresignedUrl(imageData: Data, presignedUrl: String, contentType: String) -> Observable<Bool>
    func createPrePitch(request: PrePitchCreateRequest) -> Observable<PrePitchResponse>
    func getPrePitchTypes(page: Int, pageSize: Int) -> Observable<PrePitchTypesResponse>
    func getSelectedSchools(page: Int, pageSize: Int) -> Observable<SchoolOrganizationResponse>
}

class AddSportsBriefUseCase: AddSportsBriefUseCaseProtocol {
    private let service: AddSportsBriefService
    
    init(service: AddSportsBriefService = AddSportsBriefService()) {
        self.service = service
    }
    
    func submitSportsBrief(title: String, description: String) -> Observable<Bool> {
        return service.submitSportsBrief(title: title, description: description)
    }
    
    func createPrePitchMediaLink(request: PrePitchMediaRequest) -> Observable<PrePitchMediaResponse> {
        return service.createPrePitchMediaLink(request: request)
    }
    
    func uploadImageToPresignedUrl(imageData: Data, presignedUrl: String, contentType: String) -> Observable<Bool> {
        return service.uploadImageToPresignedUrl(imageData: imageData, presignedUrl: presignedUrl, contentType: contentType)
    }
    
    func createPrePitch(request: PrePitchCreateRequest) -> Observable<PrePitchResponse> {
        return service.createPrePitch(request: request)
    }
    
    func getPrePitchTypes(page: Int, pageSize: Int) -> Observable<PrePitchTypesResponse> {
        return service.getPrePitchTypes(page: page, pageSize: pageSize)
    }
    
    func getSelectedSchools(page: Int, pageSize: Int) -> Observable<SchoolOrganizationResponse> {
        return service.getSelectedSchools(page: page, pageSize: pageSize)
    }
}
