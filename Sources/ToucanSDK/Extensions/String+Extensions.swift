//
//  String+Extensions.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 05. 14..
//

import struct Foundation.URL

extension String {

    func dropTrailingSlash() -> String {
        if hasSuffix("/") {
            return String(dropLast())
        }
        return self
    }

    func ensureTrailingSlash() -> String {
        if hasSuffix("/") {
            return self
        }
        return self + "/"
    }

    var pathIdValue: String {
        var components = split(separator: "/")
            .map {
                String($0)
            }
        guard !components.isEmpty else {
            return self
        }

        if let last = components.last, last.contains(".") {
            let fileName =
                last
                .split(separator: ".")
                .dropLast()
                .joined(separator: ".")
            components.removeLast()
            components.append(fileName)
        }

        return components.joined(separator: ".")
    }

    var baseName: String {
        URL(fileURLWithPath: self).deletingPathExtension().lastPathComponent
    }
}

#warning("move this")
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
        [:]
        //        Dictionary(
        //            uniqueKeysWithValues: map { url in
        //                let relativePath = url.relativePath(to: baseUrl)
        //                let id = relativePath.pathIdValue
        //                return (id, relativePath)
        //            }
        //        )
    }
}
