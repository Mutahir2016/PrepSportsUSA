//
//  HomeOutLinkModel.swift
//  Lumen
//
//  Created by Syed Mutahir Pirzada on 29/01/2025.
//

import Foundation

// MARK: - OutlinkModel
struct HomeOutLinkModel: Codable {
    let data: [HomeOutLinkModelData]
    let meta: Meta
    let links: Links
}

// MARK: - OutlinkData
struct HomeOutLinkModelData: Codable {
    let id, type: String?
    let attributes: HomeOutLinkModelDataAttributes
}

// MARK: - Attributes
struct HomeOutLinkModelDataAttributes: Codable {
    let id: Int?
    let name: String?
    let pageviews: Int?
    let uniquePageviews: Int?

    enum CodingKeys: String, CodingKey {
        case id, name
        case pageviews
        case uniquePageviews = "unique_pageviews"
    }
}
