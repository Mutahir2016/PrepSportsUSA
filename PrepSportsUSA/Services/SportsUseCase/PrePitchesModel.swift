//
//  PrePitchesModel.swift
//  PrepSportsUSA
//
//  Created by PrepSportsUSA on 23/08/2025.
//

import Foundation

// MARK: - PrePitches Response
struct PrePitchesModel: Codable {
    let data: [PrePitchData]
    let links: PrePitchesLinks
    let meta: PrePitchesMeta
}

// MARK: - PrePitch Data
struct PrePitchData: Codable {
    let id, type: String
    let attributes: PrePitchAttributes
}

// MARK: - PrePitch Attributes
struct PrePitchAttributes: Codable {
    let id: Int
    let name: String?
    let prePitchTypeId: String?
    let description: String?
    let payload: PrePitchPayload?
    let media: [PrePitchMedia]?
    let quotes: [String]?
    let userId: Int?
    let createdAt: String?
    let updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case id, name, description, payload, media, quotes
        case prePitchTypeId = "pre_pitch_type_id"
        case userId = "user_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - PrePitch Payload
struct PrePitchPayload: Codable {
    let limparTeam: LimparTeam?
    let limparGame: LimparGame?
    let quoteSource: String?
    let boxscore: Boxscore?
    
    enum CodingKeys: String, CodingKey {
        case limparTeam = "limpar_team"
        case limparGame = "limpar_game"
        case quoteSource = "quote_source"
        case boxscore
    }
}

// MARK: - Limpar Team
struct LimparTeam: Codable {
    let id: String?
    let name: String?
    let slug: String?
    let schoolName: String?
    let sex: String?
    let teamNickname: String?
    let sport: String?
    let sportSlug: String?
    let organizationId: String?
    let organizationName: String?
    let image: TeamImage?
    let createdAt: String?
    let updatedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id, name, slug, sex, sport, image
        case schoolName = "school_name"
        case teamNickname = "team_nickname"
        case sportSlug = "sport_slug"
        case organizationId = "organization_id"
        case organizationName = "organization_name"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - Team Image
struct TeamImage: Codable {
    let filename: String?
    let contentType: String?
    let byteSize: Int?
    let url: String?
    
    enum CodingKeys: String, CodingKey {
        case filename, url
        case contentType = "content_type"
        case byteSize = "byte_size"
    }
}

// MARK: - Limpar Game
struct LimparGame: Codable {
    let id: String?
    let venue: String?
    let dateTime: String?
    let homeTeam: GameTeam?
    let awayTeam: GameTeam?
    let createdAt: String?
    let updatedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id, venue
        case dateTime = "date_time"
        case homeTeam = "home_team"
        case awayTeam = "away_team"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - Game Team
struct GameTeam: Codable {
    let id: String?
    let name: String?
    let image: TeamImage?
}

// MARK: - Boxscore
struct Boxscore: Codable {
    let homeTeam: [String: AnyCodable]?
    let awayTeam: [String: AnyCodable]?
    
    enum CodingKeys: String, CodingKey {
        case homeTeam = "home_team"
        case awayTeam = "away_team"
    }
}

// MARK: - PrePitch Media
struct PrePitchMedia: Codable {
    let url: String?
    let filename: String?
    let caption: String?
    let credits: String?
}

// MARK: - AnyCodable for flexible JSON values
struct AnyCodable: Codable {
    let value: Any
    
    init<T>(_ value: T?) {
        self.value = value ?? ()
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let intValue = try? container.decode(Int.self) {
            value = intValue
        } else if let stringValue = try? container.decode(String.self) {
            value = stringValue
        } else if let arrayValue = try? container.decode([String].self) {
            value = arrayValue
        } else {
            value = ()
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        if let intValue = value as? Int {
            try container.encode(intValue)
        } else if let stringValue = value as? String {
            try container.encode(stringValue)
        } else if let arrayValue = value as? [String] {
            try container.encode(arrayValue)
        }
    }
}

// MARK: - PrePitchesMeta
struct PrePitchesMeta: Codable {
    let pagination: PaginationInfo?
}

// MARK: - Pagination Info
struct PaginationInfo: Codable {
    let current: Int?
    let records: Int?
}

// MARK: - PrePitchesLinks
struct PrePitchesLinks: Codable {
    let linksSelf: String?
    let current: String?

    enum CodingKeys: String, CodingKey {
        case linksSelf = "self"
        case current
    }
}
