//
//  PageViewModel.swift
//  Lumen
//
//  Created by Syed Mutahir Pirzada on 21/01/2025.
//

import Foundation

// MARK: - Stories
struct PageViewModel: Codable {
    let data: [PageViewData]
    let meta: PageViewMeta
}

// MARK: - Datum
struct PageViewData: Codable {
    let id: String
    let type: TypeEnum
    let attributes: PageViewAttributes
}

// MARK: - Attributes
struct PageViewAttributes: Codable {
    let id: String
    let resourceID: Int
    let date: String
    let pageviews, uniquePageviews: Int

    enum CodingKeys: String, CodingKey {
        case id
        case resourceID = "resource_id"
        case date, pageviews
        case uniquePageviews = "unique_pageviews"
    }
    
    
    // Computed property for formatted date
    var formattedDate: String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd" // Input format matches the JSON date format

        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "MMM dd, yyyy" // Desired output format

        if let dateObject = inputFormatter.date(from: date) {
            return outputFormatter.string(from: dateObject)
        }
        return date // Return the original date if parsing fails
    }
}

enum TypeEnum: String, Codable {
    case dailyPageview = "daily_pageview"
}

// MARK: - Meta
struct PageViewMeta: Codable {
    let pagination: Pagination
    let totalPageViews, totalUniquePageViews: Int

    enum CodingKeys: String, CodingKey {
        case pagination
        case totalPageViews = "total_pageviews"
        case totalUniquePageViews = "total_unique_pageviews"
    }
}
