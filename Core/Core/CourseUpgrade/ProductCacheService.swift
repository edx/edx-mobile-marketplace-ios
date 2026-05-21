//
//  ProductCacheService.swift
//  Core
//
//  Created by Sumanta Roy on 15.05.26.
//

import Foundation
import UIKit

//sourcery: AutoMockable
public protocol ProductCacheServiceProtocol {
    func getProduct(sku: String, using handler: CourseUpgradeHandlerProtocol) async throws -> StoreProductInfo
    func refreshProduct(sku: String, using handler: CourseUpgradeHandlerProtocol) async throws -> StoreProductInfo
    func clearCache() async
}

private actor CacheStorage {
    private struct CachedProduct {
        let product: StoreProductInfo
        let timestamp: Date
    }
    
    private var cache: [String: CachedProduct] = [:]
    private var inFlightSKUs: Set<String> = []
    private var results: [String: Result<StoreProductInfo, Error>] = [:]
    private let cacheValidityDuration: TimeInterval = 300 // 5 minutes
    
    func getCachedProduct(sku: String) -> StoreProductInfo? {
        guard let cached = cache[sku],
              Date().timeIntervalSince(cached.timestamp) < cacheValidityDuration else {
            if cache[sku] != nil {
                cache[sku] = nil // Invalidate expired entry
            }
            return nil
        }
        return cached.product
    }
    
    func getStoredResult(sku: String) -> Result<StoreProductInfo, Error>? {
        return results[sku]
    }
    
    func isInFlight(sku: String) -> Bool {
        return inFlightSKUs.contains(sku)
    }
    
    func markInFlight(sku: String) {
        inFlightSKUs.insert(sku)
    }
    
    func cacheResult(sku: String, product: StoreProductInfo) {
        cache[sku] = CachedProduct(product: product, timestamp: Date())
        results[sku] = .success(product)
        inFlightSKUs.remove(sku)
    }
    
    func cacheError(sku: String, error: Error) {
        results[sku] = .failure(error)
        inFlightSKUs.remove(sku)
    }
    
    func invalidateSKU(sku: String) {
        cache[sku] = nil
        results[sku] = nil
        inFlightSKUs.remove(sku)
    }
    
    func clearAll() {
        cache.removeAll()
        inFlightSKUs.removeAll()
        results.removeAll()
    }
}

public class ProductCacheService: ProductCacheServiceProtocol {
    private let storage = CacheStorage()
    
    public init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func appDidBecomeActive() {
        Task {
            await storage.clearAll()
        }
    }
    
    public func getProduct(sku: String, using handler: CourseUpgradeHandlerProtocol) async throws -> StoreProductInfo {
        // Check cache first
        if let cached = await storage.getCachedProduct(sku: sku) {
            return cached
        }
        
        // Check if already computed result
        if let result = await storage.getStoredResult(sku: sku) {
            return try result.get()
        }
        
        // Check if request is already in-flight
        if await storage.isInFlight(sku: sku) {
            // Wait for the fetch to complete by polling with small delay
            while true {
                try await Task.sleep(nanoseconds: 10_000_000) // 10ms
                if let cached = await storage.getCachedProduct(sku: sku) {
                    return cached
                }
                if let result = await storage.getStoredResult(sku: sku) {
                    return try result.get()
                }
            }
        }
        
        // Mark as in-flight
        await storage.markInFlight(sku: sku)
        
        do {
            let product = try await handler.fetchProduct(sku: sku)
            await storage.cacheResult(sku: sku, product: product)
            return product
        } catch {
            await storage.cacheError(sku: sku, error: error)
            throw error
        }
    }
    
    public func refreshProduct(sku: String, using handler: CourseUpgradeHandlerProtocol) async throws -> StoreProductInfo {
        // Invalidate the specific SKU to force refresh
        await storage.invalidateSKU(sku: sku)
        return try await getProduct(sku: sku, using: handler)
    }
    
    public func clearCache() async {
        await storage.clearAll()
    }
}

// MARK: - Mock for Testing

public class ProductCacheServiceMock: ProductCacheServiceProtocol {
    var getProductCallCount = 0
    var getProductSKUValues: [String] = []
    var getProductReturnValue: StoreProductInfo?
    var getProductThrowError: Error?
    var clearCacheCallCount = 0
    
    public init() {}
    
    public func getProduct(sku: String, using handler: CourseUpgradeHandlerProtocol) async throws -> StoreProductInfo {
        getProductCallCount += 1
        getProductSKUValues.append(sku)
        
        if let error = getProductThrowError {
            throw error
        }
        
        guard let product = getProductReturnValue else {
            throw NSError(domain: "ProductCacheServiceMock", code: -1, userInfo: [NSLocalizedDescriptionKey: "No mock return value set"])
        }
        
        return product
    }
    
    public func refreshProduct(sku: String, using handler: CourseUpgradeHandlerProtocol) async throws -> StoreProductInfo {
        // Mock just delegates to getProduct with fresh behavior
        getProductCallCount += 1
        getProductSKUValues.append(sku)
        
        if let error = getProductThrowError {
            throw error
        }
        
        guard let product = getProductReturnValue else {
            throw NSError(domain: "ProductCacheServiceMock", code: -1, userInfo: [NSLocalizedDescriptionKey: "No mock return value set"])
        }
        
        return product
    }
    
    public func clearCache() async {
        clearCacheCallCount += 1
    }
    
    // MARK: - Helper Methods
    
    public func reset() {
        getProductCallCount = 0
        getProductSKUValues = []
        getProductReturnValue = nil
        getProductThrowError = nil
        clearCacheCallCount = 0
    }
    
    public func verifyGetProductWasCalledWith(sku: String) -> Bool {
        return getProductSKUValues.contains(sku)
    }
    
    public func verifyGetProductCallCount(_ expected: Int) -> Bool {
        return getProductCallCount == expected
    }
}
