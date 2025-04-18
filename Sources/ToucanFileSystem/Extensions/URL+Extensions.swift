//
//  URL+Extensions.swift
//  Toucan
//
//  Created by Viasz-Kádi Ferenc on 2025. 02. 10..
//

import Foundation

extension URL {

    /// Computes a relative path from the current URL (`self`) to another base URL.
    ///
    /// This method compares the standardized path components of both URLs,
    /// identifies their shared prefix, and removes it from the current URL path
    /// to return a relative path string.
    ///
    /// - Parameter url: The base URL to which the path should be made relative.
    /// - Returns: A relative path string from `url` to `self`.
    public func relativePath(to url: URL) -> String {
        // Break both paths into components (standardized removes '.', '..', etc.)
        let components = self.standardized.pathComponents
        let baseComponents = url.standardized.pathComponents

        // Determine how many leading components are shared between both paths
        let commonPrefixCount = zip(components, baseComponents)
            .prefix { $0 == $1 }
            .count

        // Remove the common prefix to compute the relative path
        let relativeComponents = components.dropFirst(commonPrefixCount)

        // Join the remaining components with "/" to form the relative path
        return relativeComponents.joined(separator: "/")
    }
}

extension [URL] {

    /// Computes relative paths from a base URL for each `URL` in the array,
    /// and returns a dictionary grouping them by a derived `pathId`.
    ///
    /// This is useful when you want to index or categorize paths based on
    /// a stable identifier derived from their relative form.
    ///
    /// - Parameter baseUrl: The base URL to which all URLs should be made relative.
    /// - Returns: A dictionary where each key is a `pathIdValue` and the value is the corresponding relative path.
    func relativePathsGroupedByPathId(baseUrl: URL) -> [String: String] {
        Dictionary(
            uniqueKeysWithValues: map { url in
                let relativePath = url.relativePath(to: baseUrl)
                let id = relativePath.pathIdValue
                return (id, relativePath)
            }
        )
    }
}
