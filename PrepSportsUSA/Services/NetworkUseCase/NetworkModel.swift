//
//  NetworkModel.swift
//  Lumen
//
//  Created by Syed Mutahir Pirzada on 27/04/2025.
//
import Foundation

// MARK: - NetworkData
struct NetworkModel: Codable {
    let data: [NetworkDatum]
    let meta: Meta
    let links: Links
}

// MARK: - NetworkDatum
struct NetworkDatum: Codable {
    let id: String
    let type: String
    let customAttributes: CustomAttributes  // <-- New name you control

    enum CodingKeys: String, CodingKey {
        case id, type
        case customAttributes = "attributes"  // <-- Mapping JSON "attributes" to customAttributes
    }
}

// MARK: - CustomAttributes
struct CustomAttributes: Codable {  // <-- New name
    let id: Int
    let name, slug: String
}



