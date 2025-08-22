//
//  NetworkOutLinkModel.swift
//  Lumen
//
//  Created by Syed Mutahir Pirzada on 12/05/2025.
//import Foundation

// MARK: - NetworkData
struct NetworkOutLinkModel: Codable {
    let data: [NetworkOutLinkData]
    let meta: Meta
    let links: NetworkOutLinks
}

// MARK: - Datum
struct NetworkOutLinkData: Codable {
    let id: String
    let attributes: NetworkOutLinksAttributes
}

// MARK: - Attributes
struct NetworkOutLinksAttributes: Codable {
    let id: String
    let resourceID: Int
    let outlinkDomain: String
    let clicks: String?
    var nClicks: Int? {
        return Int(clicks ?? "0")
    }

    enum CodingKeys: String, CodingKey {
        case id
        case resourceID = "resource_id"
        case outlinkDomain = "outlink_domain"
        case clicks
    }
}

// MARK: - Links
struct NetworkOutLinks: Codable {
    let linksSelf, current: String

    enum CodingKeys: String, CodingKey {
        case linksSelf = "self"
        case current
    }
}

