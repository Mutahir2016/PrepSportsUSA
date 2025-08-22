//
//  GeographyModel.swift
//  Lumen
//
//  Created by Syed Mutahir Pirzada on 19/01/2025.
//


import Foundation

// MARK: - Stories
struct GeographyModel: Codable {
    let data: [GeographyData]
    let meta: Meta
    let links: Links
}

// MARK: - Datum
struct GeographyData: Codable {
    let id, type: String?
    let attributes: GeographyAttributes?
}

// MARK: - Attributes
struct GeographyAttributes: Codable {
    let id: String?
    let resourceID: Int?
    let city, region: String?
    let lat, lon: String?
    let pageviews: String?

    enum CodingKeys: String, CodingKey {
        case id
        case resourceID = "resource_id"
        case city, region, lat, lon, pageviews
    }
    
    var latitude: Double? {
        return Double(lat ?? "0")
    }
    
    var longitude: Double? {
        return Double(lon ?? "0")
    }
}
