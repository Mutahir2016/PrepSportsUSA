//
//  TopOrganizationsModel.swift
//  Lumen
//
//  Created by Syed Mutahir Pirzada on 20/01/2025.
//

import Foundation

// MARK: - Stories
struct TopOrganizationsModel: Codable {
    let data: [TopOrganizationsData]
    let meta: TopOrganizationMeta
    let links: Links
}

// MARK: - Datum
struct TopOrganizationsData: Codable {
    let id, type: String
    let attributes: TopOrganizationsAttributes
}

// MARK: - Attributes
struct TopOrganizationsAttributes: Codable {
    let id: Int
    let name: String
    let pageviews, uniquePageviews: Int?
    var pageViews: String? {
        return String(pageviews ?? 0)
    }

    enum CodingKeys: String, CodingKey {
        case id, name, pageviews
        case uniquePageviews = "unique_pageviews"
    }
}

struct TopOrganizationMeta: Codable {
    let pagination: Pagination
    let totalIdentified: Int
    let totalUnIdentified: Int
    
    enum CodingKeys: String, CodingKey {
        case pagination
        case totalIdentified = "total_identified"
        case totalUnIdentified = "total_unidentified"
    }
}
