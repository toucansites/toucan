//
//  File.swift
//  toucan
//
//  Created by Viasz-Kádi Ferenc on 2024. 10. 15..
//

import Foundation

/// A thread-safe cache to store and retrieve content context items.
///
/// - Note: This cache stores items as dictionaries keyed by strings.
class ContentContextCache {
    /// The internal storage for the cache, keyed by a string with dictionary values.
    private var _cache: [String: [String: Any]] = [:]

    /// The dispatch queue used to synchronize access to the cache.
    private let cacheQueue = DispatchQueue(
        label: "com.toucan.contentContext.cache",
        attributes: .concurrent
    )

    /// Retrieves an item from the cache for the specified key.
    ///
    /// - Parameter key: The key for which to retrieve the cached item.
    /// - Returns: The cached item as a dictionary, or `nil` if not found.
    func getItem(forKey key: String) -> [String: Any]? {
        cacheQueue.sync {
            return _cache[key]
        }
    }

    /// Adds an item to the cache for the specified key. This operation is thread-safe.
    ///
    /// - Parameters:
    ///   - item: The item to add to the cache, represented as a dictionary.
    ///   - key: The key associated with the item.
    func addItem(_ item: [String: Any], forKey key: String) {
        cacheQueue.async(flags: .barrier) {
            self._cache[key] = item
        }
    }
}
