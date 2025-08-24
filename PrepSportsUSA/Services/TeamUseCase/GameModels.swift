//
//  GameModels.swift
//  PrepSportsUSA
//
//  Created by PrepSportsUSA on 25/08/2025.
//

import Foundation

struct GameResponse: Codable {
    let data: [GameData]
    let meta: GameMeta
    let links: GameLinks
}

struct GameData: Codable {
    let id: String
    let type: String
    let attributes: GameAttributes
}

struct GameAttributes: Codable {
    let id: String
    let venue: String
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
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        venue = try container.decode(String.self, forKey: .venue)
        dateTime = try container.decode(String.self, forKey: .dateTime)
        homeTeam = try container.decode(GameTeamInfo.self, forKey: .homeTeam)
        awayTeam = try container.decode(GameTeamInfo.self, forKey: .awayTeam)
        createdAt = try container.decode(String.self, forKey: .createdAt)
        updatedAt = try container.decode(String.self, forKey: .updatedAt)
    }
}

struct GameTeamInfo: Codable {
    let id: String
    let name: String
    let image: TeamImage?
}

struct GameMeta: Codable {
    let pagination: GamePagination
}

struct GamePagination: Codable {
    let current: Int
    let records: Int
}

struct GameLinks: Codable {
    let selfLink: String
    let current: String
    
    enum CodingKeys: String, CodingKey {
        case selfLink = "self"
        case current
    }
}
