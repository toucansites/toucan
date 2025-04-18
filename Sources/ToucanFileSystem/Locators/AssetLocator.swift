//
//  AssetLocator.swift
//  Toucan
//
//  Created by Viasz-Kádi Ferenc on 2025. 03. 03..
//

import Foundation
import FileManagerKit

/// A structure for locating asset file paths from the filesystem, starting from a base directory.
public struct AssetLocator {

    /// The file manager used for accessing and interacting with the filesystem.
    private let fileManager: FileManagerKit

    /// Initializes the asset locator with a file manager instance.
    ///
    /// - Parameter fileManager: An abstraction for interacting with the filesystem.
    public init(fileManager: FileManagerKit) {
        self.fileManager = fileManager
    }

    /// Recursively locates all non-hidden assets under the given directory.
    ///
    /// - Parameter url: The root directory to scan.
    /// - Returns: A list of relative paths (as strings) to the located assets, excluding hidden files (e.g. files starting with `.`).
    public func locate(at url: URL) -> [String] {
        fileManager
            .listDirectoryRecursively(at: url)
            .map {
                // Convert to a relative path based on the root URL
                $0.relativePath(to: url)
            }
            .filter {
                // Exclude dot-prefixed (hidden) files or directories
                !$0.hasPrefix(".")
            }
    }
}
