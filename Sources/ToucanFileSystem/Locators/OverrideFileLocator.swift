//
//  OverrideFileLocator.swift
//  Toucan
//
//  Created by Binary Birds on 2025. 04. 17..

import Foundation
import FileManagerKit
import ToucanModels

/// A structure for locating files and their overrides from the filesystem.
public struct OverrideFileLocator {

    // MARK: - Properties

    /// File manager used to list and access the filesystem.
    private let fileManager: FileManagerKit

    /// An internal `FileLocator` used to perform the actual file filtering by extension.
    private let fileLocator: FileLocator

    // MARK: - Initialization

    /// Initializes the file locator with optional extension filters.
    ///
    /// - Parameters:
    ///   - fileManager: The file manager abstraction.
    ///   - extensions: Optional file extensions to filter on (e.g., `["html", "yml"]`).
    public init(
        fileManager: FileManagerKit,
        extensions: [String]? = nil
    ) {
        self.fileManager = fileManager
        self.fileLocator = .init(
            fileManager: fileManager,
            extensions: extensions
        )
    }

    // MARK: - Locating Files with Overrides

    /// Locates files at a primary location and matches them with overrides, if present.
    ///
    /// - Parameters:
    ///   - url: The base directory containing the default files.
    ///   - overridesUrl: The directory containing optional override files.
    /// - Returns: A sorted list of `OverrideFileLocation` entries, each pairing a base file with its override.
    public func locate(
        at url: URL,
        overrides overridesUrl: URL
    ) -> [OverrideFileLocation] {
        let paths = fileLocator.locate(at: url)
        let overridesPaths = fileLocator.locate(at: overridesUrl)

        // Group override files by their base name (filename without extension)
        let overridesPathsDict = Dictionary(
            grouping: overridesPaths,
            by: \.baseName
        )

        // Build the override mapping list
        return
            paths
            .map { path in
                let overridePath = overridesPathsDict[path.baseName]?.first
                return .init(path: path, overridePath: overridePath)
            }
            .sorted { $0.path < $1.path }
    }
}
