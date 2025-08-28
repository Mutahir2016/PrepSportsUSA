//
//  TeamModels.swift
//  PrepSportsUSA
//
//  Created by PrepSportsUSA on 25/08/2025.
//

import Foundation

// MARK: - Team Response Models
struct TeamResponse: Codable {
    let data: [TeamData]
    let meta: TeamMeta
    let links: TeamLinks
}

struct TeamData: Codable {
    let id: String
    let type: String
    let attributes: TeamAttributes
}

struct TeamAttributes: Codable {
    let id: String
    let name: String
    let slug: String
    let schoolName: String
    let sex: String
    let teamNickname: String
    let sport: String
    let image: TeamImage?
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, name, slug, sex, sport, image
        case schoolName = "school_name"
        case teamNickname = "team_nickname"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        slug = try container.decode(String.self, forKey: .slug)
        schoolName = try container.decode(String.self, forKey: .schoolName)
        sex = try container.decode(String.self, forKey: .sex)
        teamNickname = try container.decode(String.self, forKey: .teamNickname)
        sport = try container.decode(String.self, forKey: .sport)
        image = try container.decodeIfPresent(TeamImage.self, forKey: .image)
        createdAt = try container.decode(String.self, forKey: .createdAt)
        updatedAt = try container.decode(String.self, forKey: .updatedAt)
    }
    
    // Computed property to convert Men/Women to Boys/Girls
    var displaySex: String {
        switch sex.lowercased() {
        case "men":
            return "Boys"
        case "women":
            return "Girls"
        default:
            return sex
        }
    }
}

struct TeamMeta: Codable {
    let pagination: TeamPagination
}

struct TeamPagination: Codable {
    let current: Int
    let records: Int
}

struct TeamLinks: Codable {
    let selfLink: String
    let current: String
    
    enum CodingKeys: String, CodingKey {
        case selfLink = "self"
        case current
    }
}
