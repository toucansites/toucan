//
//  URL+Extensions.swift
//  toucan
//
//  Created by Viasz-Kádi Ferenc on 2025. 02. 10..
//

import Foundation

extension URL {

    public func relativePath(to url: URL) -> String {
        let components = self.standardized.pathComponents
        let baseComponents = url.standardized.pathComponents

        // Find common prefix length
        let commonPrefixCount = zip(components, baseComponents)
            .prefix { $0 == $1 }
            .count

        // Get the relative components by dropping the common ones
        let relativeComponents = components.dropFirst(commonPrefixCount)

        return relativeComponents.joined(separator: "/")
    }
}

extension [URL] {

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
