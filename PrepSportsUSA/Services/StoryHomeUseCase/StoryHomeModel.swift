//
//  StoryHomeModel.swift
//  Lumen
//
//  Created by Syed Mutahir Pirzada on 12/01/2025.
//
import Foundation


// MARK: - Stories
struct StoryHomeModel: Codable {
    let data: [Story]
    let meta: Meta
}

// MARK: - Story
struct Story: Codable {
    let id: String
    let attributes: Attributes
}

// MARK: - Attributes
struct Attributes: Codable {
    let id: Int?
    let headline: String?
    let publishedAt: Date?
    let publicURL: String?
    let project: String?
    let pitchDate: String?
    let pageviews, uniquePageviews: Int?

    enum CodingKeys: String, CodingKey {
        case id, headline
        case publishedAt = "published_at"
        case publicURL = "public_url"
        case project
        case pitchDate = "pitch_date"
        case pageviews
        case uniquePageviews = "unique_pageviews"
    }
}


// MARK: - Meta
struct Meta: Codable {
    let pagination: Pagination
    let totalClicks: Int?
    
    enum CodingKeys: String, CodingKey {
        case pagination
        case totalClicks = "total_clicks"
    }
}

// MARK: - Pagination
struct Pagination: Codable {
    let current: Int
    let records: Int
}
