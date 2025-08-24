//
//  SchoolOrganizationModels.swift
//  PrepSportsUSA
//
//  Created by PrepSportsUSA on 25/08/2025.
//

import Foundation

struct SchoolOrganizationResponse: Codable {
    let data: [SchoolOrganizationData]
    let meta: SchoolOrganizationMeta
    let links: SchoolOrganizationLinks
}

struct SchoolOrganizationData: Codable {
    let id: String
    let type: String
    let attributes: SchoolOrganizationAttributes
}

struct SchoolOrganizationAttributes: Codable {
    let id: String
    let name: String
    let slug: String
    let city: String?
    let state: String?
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, name, slug, city, state
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct SchoolOrganizationMeta: Codable {
    let pagination: SchoolOrganizationPagination
}

struct SchoolOrganizationPagination: Codable {
    let current: Int
    let records: Int
}

struct SchoolOrganizationLinks: Codable {
    let `self`: String
    let current: String
}
