//
//  PaginationResult.swift
//  Core
//
//  Created by Muhammad Tayyab  Akram on 1/30/25.
//

import Foundation

/// A structure representing the result of a paginated fetch operation.
public struct PaginationResult<Item, PaginationKey> {
    /// The list of items fetched in the current page.
    public let items: [Item]
    /// An optional key used to fetch the next page. `nil` indicates that no more pages are available.
    public let nextPageKey: PaginationKey?
    
    /// Initializes a `PaginationResult` with the fetched items and an optional pagination key.
    ///
    /// - Parameters:
    ///   - items: The list of items fetched in the current page.
    ///   - nextPageKey: An optional key used to fetch the next page. Defaults to `nil`.
    public init(items: [Item], nextPageKey: PaginationKey? = nil) {
        self.items = items
        self.nextPageKey = nextPageKey
    }
}
