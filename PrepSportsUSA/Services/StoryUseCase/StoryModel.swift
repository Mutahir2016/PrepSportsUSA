//
//  StoryModel.swift
//  Lumen
//
//  Created by Syed Mutahir Pirzada on 21/01/2025.
//

import Foundation

// MARK: - Stories
struct StoryModel: Codable {
    let data: StoryModelData
    let links: Links
}

// MARK: - DataClass
struct StoryModelData: Codable {
    let id, type: String?
    let attributes: StoryModelAttributes
}

// MARK: - Attributes
struct StoryModelAttributes: Codable {
    let id: Int?
    let headline: String?
    let publishedAt: Date?
    let publicURL: String?
    let project: String?
    let pitchDate: Date?
    let pageviews, uniquePageviews: Int?
    let averageTime: Double?

    enum CodingKeys: String, CodingKey {
        case id, headline
        case publishedAt = "published_at"
        case publicURL = "public_url"
        case project
        case pitchDate = "pitch_date"
        case pageviews
        case uniquePageviews = "unique_pageviews"
        case averageTime = "average_time"
    }
}
