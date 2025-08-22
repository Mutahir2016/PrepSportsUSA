//
//  UserProfile.swift
//  Lumen
//
//  Created by Syed Mutahir Pirzada on 30/01/2025.
//

import Foundation

// MARK: - UserProfile
struct UserProfile: Codable {
    let data: UserProfileData
    let links: UserProfileLinks
}

// MARK: - DataClass
struct UserProfileData: Codable {
    let id, type: String
    let attributes: UserProfileAttributes
}

// MARK: - Attributes
struct UserProfileAttributes: Codable {
    let id: Int?
    let email, name: String?
    let managerID: String?
    let agencyID: String?
    let isAgencyAdmin: Bool
    let accountType: String?

    enum CodingKeys: String, CodingKey {
        case id, email, name
        case managerID = "manager_id"
        case agencyID = "agency_id"
        case isAgencyAdmin = "is_agency_admin"
        case accountType = "account_type"
    }
}

// MARK: - Links
struct UserProfileLinks: Codable {
    let linksSelf: String

    enum CodingKeys: String, CodingKey {
        case linksSelf = "self"
    }
}
