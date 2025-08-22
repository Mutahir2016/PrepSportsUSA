//
//  HomeStoryModel.swift
//  Lumen
//
//  Created by Syed Mutahir Pirzada on 29/01/2025.
//

import Foundation

// MARK: - StoryModel
struct HomeStoryModel: Codable {
    let data: [HomeStoryModelData]
}

// MARK: - StoryModelData
struct HomeStoryModelData: Codable {
    let id, type: String
    let attributes: StoryModelAttributes
}
