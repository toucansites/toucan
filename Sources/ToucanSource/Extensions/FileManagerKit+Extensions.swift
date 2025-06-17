//
//  FileManagerKit+Extensions.swift
//  Toucan
//
//  Created by Binary Birds on 2025. 04. 17..

import FileManagerKit
import struct Foundation.URL

private extension URL {
    /// Computes a relative path from the current URL (`self`) to another base URL.
    ///
    /// This method compares the standardized path components of both URLs,
    /// identifies their shared prefix, and removes it from the current URL path
    /// to return a relative path string.
    ///
    /// - Parameter url: The base URL to which the path should be made relative.
    /// - Returns: A relative path string from `url` to `self`.
    func relativePath(to url: URL) -> String {
        // Break both paths into components (standardized removes '.', '..', etc.)
        let components = standardized.pathComponents
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

public extension FileManagerKit {
    /// Find files in the specified directory that match the given name and extensions criteria.
    ///
    /// - Parameters: url: The URL of the directory to search.
    /// - Returns: An array of file names that match the specified criteria.
    func find(
        name: String? = nil,
        extensions: [String]? = nil,
        recursively: Bool = false,
        skipHiddenFiles: Bool = true,
        at url: URL
    ) -> [String] {
        var items: [String] = []
        if recursively {
            items = listDirectoryRecursively(at: url)
                .map {
                    // Convert to a relative path based on the root URL
                    $0.relativePath(to: url)
                }
        }
        else {
            items = listDirectory(at: url)
        }

        if skipHiddenFiles {
            items = items.filter { !$0.hasPrefix(".") }
        }
        return items.filter { fileName in
            let fileURL = URL(fileURLWithPath: fileName)
            let baseName = fileURL.deletingPathExtension().lastPathComponent
            let ext = fileURL.pathExtension

            switch (name, extensions) {
            case (nil, nil):
                return true
            case (let name?, nil):
                return baseName == name
            case (nil, let extensions?):
                return extensions.contains(ext)
            case let (name?, extensions?):
                return baseName == name && extensions.contains(ext)
            }
        }
    }
}
