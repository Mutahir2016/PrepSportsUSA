//
//  SearchViewModel.swift
//  Lumen
//
//  Created by Assistant on 24/12/2024.
//

import Foundation
import RxSwift
import RxCocoa

class SearchViewModel: BaseViewModel {
    
    // MARK: - Input
    let searchText = BehaviorRelay<String>(value: "")
    let searchTrigger = PublishSubject<String>()
    
    // MARK: - Output
    let searchResults = BehaviorRelay<[SearchStoryItem]>(value: [])
    let isLoading = BehaviorRelay<Bool>(value: false)
    let hasResults = BehaviorRelay<Bool>(value: false)
    let errorMessage = BehaviorRelay<String?>(value: nil)
    let totalCount = BehaviorRelay<Int>(value: 0)
    let hasMorePages = BehaviorRelay<Bool>(value: false)
    
    // MARK: - Properties
    weak var delegate: SearchViewModelDelegate?
    private let searchUseCase: SearchUseCase
    private let router: SearchRouter
    private var currentPage = 1
    private let pageSize = 20
    private var isLoadingMore = false
    
    // MARK: - Init
    init(router: SearchRouter, searchUseCase: SearchUseCase = SearchUseCase()) {
        self.router = router
        self.searchUseCase = searchUseCase
        super.init()
        setupBindings()
    }
    
    // MARK: - Setup
    private func setupBindings() {
        // Bind search trigger to search action (only when button is pressed)
        searchTrigger
            .filter { !$0.isEmpty } // Search with any non-empty text
            .flatMapLatest { [weak self] query -> Observable<SearchStoriesResult> in
                guard let self = self else { return Observable.empty() }
                self.currentPage = 1
                self.isLoading.accept(true)
                self.errorMessage.accept(nil)
                
                return self.searchUseCase.searchStories(query: query, pageNumber: self.currentPage, pageSize: self.pageSize)
                    .do(onNext: { _ in
                        self.isLoading.accept(false)
                    }, onError: { error in
                        self.isLoading.accept(false)
                        self.errorMessage.accept("Search failed. Please try again.")
                        print("Search error: \(error)")
                    })
                    .catchAndReturn(SearchStoriesResult(stories: [], totalCount: 0, totalPages: 0, currentPage: 1, hasMorePages: false))
            }
            .subscribe(onNext: { [weak self] result in
                self?.searchResults.accept(result.stories)
                self?.totalCount.accept(result.totalCount)
                self?.hasMorePages.accept(result.hasMorePages)
                self?.currentPage = result.currentPage
            })
            .disposed(by: disposeBag)
        
        // Update has results
        searchResults
            .map { !$0.isEmpty }
            .bind(to: hasResults)
            .disposed(by: disposeBag)
    }
    
    // MARK: - Actions
    func viewWillAppear() {
        // Handle view will appear
    }
    
    func performSearch(with query: String) {
        searchText.accept(query)
        searchTrigger.onNext(query)
    }
    
    func clearSearch() {
        searchResults.accept([])
        hasResults.accept(false)
        totalCount.accept(0)
        hasMorePages.accept(false)
        errorMessage.accept(nil)
        currentPage = 1
    }
    
    func loadMoreResults() {
        guard hasMorePages.value && !isLoadingMore && !searchText.value.isEmpty else { return }
        
        isLoadingMore = true
        let nextPage = currentPage + 1
        
        searchUseCase.searchStories(query: searchText.value, pageNumber: nextPage, pageSize: pageSize)
            .subscribe(
                onNext: { [weak self] result in
                    guard let self = self else { return }
                    
                    let currentResults = self.searchResults.value
                    let newResults = currentResults + result.stories
                    
                    self.searchResults.accept(newResults)
                    self.hasMorePages.accept(result.hasMorePages)
                    self.currentPage = result.currentPage
                    self.isLoadingMore = false
                },
                onError: { [weak self] error in
                    self?.isLoadingMore = false
                    self?.errorMessage.accept("Failed to load more results")
                    print("Load more error: \(error)")
                }
            )
            .disposed(by: disposeBag)
    }
    
    func didSelectStory(_ story: SearchStoryItem) {
        router.routeToStoryDetails(story.id)
    }
}

// MARK: - SearchViewModelDelegate
protocol SearchViewModelDelegate: AnyObject {
    func searchViewModel(_ viewModel: SearchViewModel, didSelectStory story: SearchStoryItem)
    func searchViewModel(_ viewModel: SearchViewModel, didFailWithError error: String)
} 
