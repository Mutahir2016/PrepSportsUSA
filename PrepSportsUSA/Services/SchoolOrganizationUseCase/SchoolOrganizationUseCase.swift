//
//  SchoolOrganizationUseCase.swift
//  PrepSportsUSA
//
//  Created by PrepSportsUSA on 25/08/2025.
//

import Foundation
import RxSwift

protocol SchoolOrganizationUseCaseProtocol {
    func getSchoolOrganizations(pageSize: Int, pageNumber: Int, name: String?) -> Observable<SchoolOrganizationResponse?>
}

class SchoolOrganizationUseCase: SchoolOrganizationUseCaseProtocol {
    private let service: SchoolOrganizationService
    
    init(service: SchoolOrganizationService = SchoolOrganizationService()) {
        self.service = service
    }
    
    func getSchoolOrganizations(pageSize: Int, pageNumber: Int, name: String? = nil) -> Observable<SchoolOrganizationResponse?> {
        return service.getSchoolOrganizations(pageSize: pageSize, pageNumber: pageNumber, name: name)
    }
}
