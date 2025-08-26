//
//  GameModels.swift
//  PrepSportsUSA
//
//  Created by PrepSportsUSA on 25/08/2025.
//

import Foundation

// MARK: - Root Response
struct GameResponse: Codable {
    let data: [GameData]
    let meta: GameMeta
    let links: GameLinks
}

// MARK: - Data
struct GameData: Codable {
    let id: String
    let type: String
    let attributes: GameAttributes
}

// MARK: - Attributes
struct GameAttributes: Codable {
    let id: String
    let venue: String?
    let dateTime: String
    let homeTeam: GameTeamInfo
    let awayTeam: GameTeamInfo
    let createdAt: String
    let updatedAt: String

    enum CodingKeys: String, CodingKey {
        case id, venue
        case dateTime = "date_time"
        case homeTeam = "home_team"
        case awayTeam = "away_team"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - Team Info
struct GameTeamInfo: Codable {
    let id: String
    let name: String
    let image: TeamImage?
}

// MARK: - Team Image
struct TeamImage: Codable {
    let filename: String?
    let contentType: String?
    let byteSize: Int?
    let url: String?

    enum CodingKeys: String, CodingKey {
        case filename
        case contentType = "content_type"
        case byteSize = "byte_size"
        case url
    }
}

// MARK: - Meta
struct GameMeta: Codable {
    let pagination: GamePagination
}

struct GamePagination: Codable {
    let current: Int
    let records: Int
}

// MARK: - Links
struct GameLinks: Codable {
    let selfLink: String
    let current: String

    enum CodingKeys: String, CodingKey {
        case selfLink = "self"
        case current
    }
}

