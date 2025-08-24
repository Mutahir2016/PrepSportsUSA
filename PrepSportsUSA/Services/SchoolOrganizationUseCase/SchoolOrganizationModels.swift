//
//  SchoolOrganizationModels.swift
//  PrepSportsUSA
//
//  Created by PrepSportsUSA on 25/08/2025.
//

import Foundation

// MARK: - School Organization Response Models
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
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, name
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
    let selfLink: String
    let current: String
    
    enum CodingKeys: String, CodingKey {
        case selfLink = "self"
        case current
    }
}
