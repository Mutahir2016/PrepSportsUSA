//
//  AddSportsBriefModels.swift
//  PrepSportsUSA
//
//  Created by PrepSportsUSA on 25/08/2025.
//

import Foundation
import UIKit

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
        } else if let intArrayValue = try? container.decode([Int].self) {
            value = intArrayValue
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
        } else if let intArrayValue = value as? [Int] {
            try container.encode(intArrayValue)
        }
    }
}

// MARK: - Pre Pitch Create Request
struct PrePitchCreateRequest: Codable {
    let prePitchTypeId: String
    let limparTeamId: String
    let limparGameId: String
    let description: String
    let media: [MediaRequest]
    let quotes: [String]
    let quoteSource: String
    let boxscore: GenericBoxscore
    
    enum CodingKeys: String, CodingKey {
        case prePitchTypeId = "pre_pitch_type_id"
        case limparTeamId = "limpar_team_id"
        case limparGameId = "limpar_game_id"
        case description, media, quotes
        case quoteSource = "quote_source"
        case boxscore
    }
}

// MARK: - Media Request
struct MediaRequest: Codable {
    let url: String
    let filename: String
    let caption: String
    let credits: String
}

// MARK: - Generic Boxscore
struct GenericBoxscore: Codable {
    let homeTeam: [String: AnyCodable]
    let awayTeam: [String: AnyCodable]
    
    enum CodingKeys: String, CodingKey {
        case homeTeam = "home_team"
        case awayTeam = "away_team"
    }
}

// MARK: - Pre Pitch Media Request
struct PrePitchMediaRequest: Codable {
    let filename: String
    let contentType: String
    
    enum CodingKeys: String, CodingKey {
        case filename
        case contentType = "content_type"
    }
}

// MARK: - Pre Pitch Media Response
struct PrePitchMediaResponse: Codable {
    let presignedUrl: String
    let publicUrl: String
    
    enum CodingKeys: String, CodingKey {
        case presignedUrl = "presigned_url"
        case publicUrl = "public_url"
    }
}

// MARK: - Pre Pitch Response
struct PrePitchResponse: Codable {
    let data: PrePitchData
}

// MARK: - Uploaded Image Model
struct UploadedImage {
    let image: UIImage
    let name: String
    let publicUrl: String?
    let contentType: String
    let size: Int64
    var caption: String?
    var credit: String?
}

// MARK: - Pre Pitch Types Response
struct PrePitchTypesResponse: Codable {
    let data: [PrePitchTypeData]
}

struct PrePitchTypeData: Codable {
    let id: String
    let type: String
    let attributes: PrePitchTypeAttributes
}

struct PrePitchTypeAttributes: Codable {
    let id: String
    let name: String
    let slug: String
}
