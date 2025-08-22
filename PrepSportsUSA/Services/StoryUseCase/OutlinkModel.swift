//
//  OutlinkModel.swift
//  Lumen
//
//  Created by Syed Mutahir Pirzada on 20/01/2025.
//

import Foundation

// MARK: - Stories
struct OutlinkModel: Codable {
    let data: [OutlinkData]
    let meta: Meta
    let links: Links
}

// MARK: - Datum
struct OutlinkData: Codable {
    let id, type: String?
    let attributes: OutlinkAttributes
}

// MARK: - Attributes
struct OutlinkAttributes: Codable {
    let id: String?
    let resourceID: Int?
    let outlinkDomain: String?
    let clicks: Int? // Keep as Int, but decode from String

    enum CodingKeys: String, CodingKey {
        case id
        case resourceID = "resource_id"
        case outlinkDomain = "outlink_domain"
        case clicks
    }

    // Custom initializer to decode clicks as Int from String
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        resourceID = try container.decodeIfPresent(Int.self, forKey: .resourceID)
        outlinkDomain = try container.decodeIfPresent(String.self, forKey: .outlinkDomain)
        
        // Decode clicks as a string, then convert to Int
        if let clicksString = try container.decodeIfPresent(String.self, forKey: .clicks),
           let clicksValue = Int(clicksString) {
            clicks = clicksValue
        } else {
            clicks = nil
        }
    }
}
