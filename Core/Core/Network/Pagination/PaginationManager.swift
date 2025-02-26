//
//  PaginationManager.swift
//  Notifications
//
//  Created by Muhammad Tayyab  Akram on 1/29/25.
//

import Foundation
import Combine

/// A generic pagination manager that supports different pagination strategies.
///
/// This class manages paginated data fetching, providing publishers for items, loading states, and errors.
/// It supports refreshing data from the first page and loading additional pages using a pagination key.
public final class PaginationManager<Item, PaginationKey> {
    /// A closure that fetches a page of items asynchronously.
    ///
    /// - Parameter pageKey: An optional pagination key used to fetch the next page. Pass `nil` to fetch the first page.
    /// - Returns: A `PaginationResult` containing the fetched items and the next pagination key.
    public typealias FetchPage = (PaginationKey?) async throws -> PaginationResult<Item, PaginationKey>
    
    private let fetchPage: FetchPage
    
    private let isRefreshingSubject = CurrentValueSubject<Bool, Never>(false)
    private let isLoadingMoreSubject = CurrentValueSubject<Bool, Never>(false)
    private let itemsSubject = CurrentValueSubject<[Item]?, Never>(nil)
    private let errorSubject = PassthroughSubject<Error, Never>()
    
    private var nextPageKey: PaginationKey?
    
    private var refreshTask: PaginationTask<Item>? {
        didSet {
            isRefreshingSubject.send(refreshTask != nil)
        }
    }
    
    private var loadMoreTask: PaginationTask<Item>? {
        didSet {
            isLoadingMoreSubject.send(loadMoreTask != nil)
        }
    }
    
    // MARK: - Publishers
    
    /// A publisher that emits whether a refresh operation is currently in progress.
    public var isRefreshingPublisher: AnyPublisher<Bool, Never> {
        isRefreshingSubject.eraseToAnyPublisher()
    }

    /// A publisher that emits whether a load-more operation is currently in progress.
    public var isLoadingMorePublisher: AnyPublisher<Bool, Never> {
        isLoadingMoreSubject.eraseToAnyPublisher()
    }
    
    /// A publisher that emits the current list of fetched items.
    ///
    /// - Note: The emitted value is `nil` when no items have been fetched yet.
    public var itemsPublisher: AnyPublisher<[Item]?, Never> {
        itemsSubject.eraseToAnyPublisher()
    }
    
    /// A publisher that emits errors encountered during fetching.
    public var errorPublisher: AnyPublisher<Error, Never> {
        errorSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Initialization
    
    /// Initializes the `PaginationManager` with a closure for fetching paginated data.
    ///
    /// - Parameter fetchPage: A closure that takes an optional pagination key and returns
    ///                        paginated results asynchronously.
    public init(fetchPage: @escaping FetchPage) {
        self.fetchPage = fetchPage
    }
    
    // MARK: - Public Methods
    
    /// Resets the pagination state by clearing stored items and the next page key.
    ///
    /// This method cancels any ongoing refresh or load-more tasks and sets the items to `nil`.
    @MainActor
    public func reset() {
        refreshTask?.cancel()
        loadMoreTask?.cancel()
        nextPageKey = nil
        itemsSubject.send(nil)
    }
    
    /// Refreshes data by fetching the first page.
    ///
    /// - Returns: A `PaginationTask` representing the ongoing refresh operation.
    /// - Note: If a refresh task is already running and not cancelled, this method returns the existing task.
    @MainActor
    @discardableResult
    public func refresh() -> PaginationTask<Item> {
        if refreshTask == nil || refreshTask?.isCancelled == true {
            refreshTask = PaginationTask.create { newTask in
                try await self.fetchData(
                    refresh: true,
                    associatedTask: newTask
                )
            }
        }
        
        return refreshTask!
    }
    
    /// Loads the next page of data if available.
    ///
    /// - Returns: A `PaginationTask` representing the ongoing load-more operation, or `nil` if no
    ///            more pages are available.
    /// - Note: If a load-more task is already running and not cancelled, this method returns the existing task.
    @MainActor
    @discardableResult
    public func loadMore() -> PaginationTask<Item>? {
        if loadMoreTask == nil || loadMoreTask?.isCancelled == true {
            guard nextPageKey != nil else { return nil }
            
            loadMoreTask = PaginationTask.create { newTask in
                try await self.fetchData(
                    refresh: false,
                    associatedTask: newTask
                )
            }
        }
        
        return loadMoreTask
    }
    
    // MARK: - Private Methods
    
    @MainActor
    private func fetchData(
        refresh: Bool,
        associatedTask: PaginationTask<Item>
    ) async throws -> [Item] {
        try await withTaskCancellationHandler {
            defer {
                clearTask(associatedTask)
            }
            
            do {
                let pageKey = refresh ? nil : nextPageKey
                let result = try await fetchPage(pageKey)
                let updatedItems: [Item]
                
                try Task.checkCancellation()
                
                if refresh {
                    loadMoreTask?.cancel()
                    updatedItems = result.items
                } else {
                    updatedItems = (itemsSubject.value ?? []) + result.items
                }
                
                nextPageKey = result.nextPageKey
                itemsSubject.send(updatedItems)
                return updatedItems
            } catch {
                if !Task.isCancelled {
                    errorSubject.send(error)
                }
                throw error
            }
        } onCancel: {
            Task { @MainActor in
                clearTask(associatedTask)
            }
        }
    }
    
    @MainActor
    private func clearTask(_ paginationTask: PaginationTask<Item>) {
        if paginationTask == refreshTask {
            refreshTask = nil
        }
        if paginationTask == loadMoreTask {
            loadMoreTask = nil
        }
    }
}
