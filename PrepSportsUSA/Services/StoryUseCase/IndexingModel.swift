//
//  IndexingModel.swift
//  Lumen
//
//  Created by Syed Mutahir Pirzada on 18/01/2025.
//

// MARK: - Stories
struct IndexingModel: Codable {
    let data: IndexingData
    let links: Links
}

// MARK: - DataClass
struct IndexingData: Codable {
    let id, type: String
    let attributes: IndexAttributes
}

// MARK: - Attributes
struct IndexAttributes: Codable {
    let id: String
    let resourceID: Int
    let position: String
    let impressions: Int?
    let ctr: String
    let clicks: Int
    var positionValue: Double? {
            return Double(position)
    }

    enum CodingKeys: String, CodingKey {
        case id
        case resourceID = "resource_id"
        case position, impressions, ctr, clicks
    }
}

// MARK: - Links
struct Links: Codable {
    let linksSelf: String

    enum CodingKeys: String, CodingKey {
        case linksSelf = "self"
    }
}
