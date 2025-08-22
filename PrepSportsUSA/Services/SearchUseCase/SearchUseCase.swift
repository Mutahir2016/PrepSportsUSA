//
//  SearchUseCase.swift
//  Lumen
//
//  Created by Assistant on 24/12/2024.
//

import Foundation
import RxSwift

class SearchUseCase {
    
    private let searchService: SearchService
    
    init(searchService: SearchService = SearchService()) {
        self.searchService = searchService
    }
    
    func searchStories(query: String, pageNumber: Int = 1, pageSize: Int = 20) -> Observable<SearchStoriesResult> {
        return searchService.searchStories(query: query, pageNumber: pageNumber, pageSize: pageSize)
            .map { response in
                let stories = response.data.map { storyData in
                    SearchStoryItem(
                        id: storyData.id ?? "",
                        headline: storyData.attributes.headline ?? "No Title",
                        project: storyData.attributes.project ?? "",
                        publishedAt: storyData.attributes.publishedAt,
                        pageviews: storyData.attributes.pageviews ?? 0,
                        uniquePageviews: storyData.attributes.uniquePageviews ?? 0,
                        publicURL: storyData.attributes.publicURL,
                        storyData: storyData
                    )
                }
                
                let currentPage = response.meta?.pagination.current ?? 1
                let totalRecords = response.meta?.pagination.records ?? stories.count
                let totalPages = Int(ceil(Double(totalRecords) / Double(pageSize)))
                
                return SearchStoriesResult(
                    stories: stories,
                    totalCount: totalRecords,
                    totalPages: totalPages,
                    currentPage: currentPage,
                    hasMorePages: currentPage < totalPages
                )
            }
    }
}

// MARK: - Search Result Models
struct SearchStoriesResult {
    let stories: [SearchStoryItem]
    let totalCount: Int
    let totalPages: Int
    let currentPage: Int
    let hasMorePages: Bool
}

struct SearchStoryItem {
    let id: String
    let headline: String
    let project: String
    let publishedAt: Date?
    let pageviews: Int
    let uniquePageviews: Int
    let publicURL: String?
    let storyData: StoryModelData
    
    var displaySubtitle: String {
        var components: [String] = []
        
        if !project.isEmpty {
            components.append(project)
        }
        
        if pageviews > 0 {
            components.append("\(pageviews) views")
        }
        
        if let publishedAt = publishedAt {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            components.append(formatter.string(from: publishedAt))
        }
        
        return components.joined(separator: " • ")
    }
    
    // Convert SearchStoryItem to Story format for cell configuration
    func toStoryModel() -> Story {
        let attributes = Attributes(
            id: Int(id),
            headline: headline,
            publishedAt: publishedAt,
            publicURL: publicURL,
            project: project,
            pitchDate: nil,
            pageviews: pageviews,
            uniquePageviews: uniquePageviews
        )
        
        return Story(id: id, attributes: attributes)
    }
} 