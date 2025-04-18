//
//  TemplateLocator.swift
//  Toucan
//
//  Created by Viasz-Kádi Ferenc on 2025. 02. 04..
//

import Foundation
import FileManagerKit
import ToucanModels

import Foundation
import FileManagerKit
import ToucanModels

/// Locates Mustache template files in a directory, supporting override resolution.
///
/// `TemplateLocator` searches recursively for files with a `.mustache` extension
/// in both a primary and override directory. If an override is found for a given template ID,
/// it takes precedence over the original.
public struct TemplateLocator {

    /// File manager abstraction for interacting with the filesystem.
    private let fileManager: FileManagerKit

    /// File extension expected for templates.
    private let ext = "mustache"

    /// Initializes a `TemplateLocator` with a file manager.
    ///
    /// - Parameter fileManager: The file manager used to access the file system.
    public init(fileManager: FileManagerKit) {
        self.fileManager = fileManager
    }

    /// Locates all templates in a given directory and its overrides, returning sorted results.
    ///
    /// - Parameters:
    ///   - url: The base directory where templates are stored.
    ///   - overrides: The override directory with higher precedence.
    /// - Returns: A list of `TemplateLocation` objects, sorted by ID.
    public func locate(at url: URL, overrides: URL) -> [TemplateLocation] {
        locateTemplateLocations(at: url, overrides: overrides)
            .sorted { $0.id < $1.id }
    }
}

private extension TemplateLocator {

    /// Recursively locates `.mustache` templates in both the base and override directories.
    ///
    /// Override templates take precedence and will replace base templates if the same ID is found.
    ///
    /// - Parameters:
    ///   - url: The primary template folder.
    ///   - overridesUrl: The override folder that can shadow base templates.
    /// - Returns: A merged list of template file paths, keyed by unique ID.
    func locateTemplateLocations(
        at url: URL,
        overrides overridesUrl: URL
    ) -> [TemplateLocation] {
        // Map override templates by ID
        let overrideLocations =
            fileManager
            .listDirectoryRecursively(at: overridesUrl)
            .relativePathsGroupedByPathId(baseUrl: overridesUrl)
            .filter { $1.hasSuffix(".\(ext)") }

        // Map base templates by ID
        var locations =
            fileManager
            .listDirectoryRecursively(at: url)
            .relativePathsGroupedByPathId(baseUrl: url)
            .filter { $1.hasSuffix(".\(ext)") }

        // Override base templates with override versions when available
        for (id, path) in overrideLocations {
            if locations[id] != nil {
                locations[id] = path
            }
        }

        // Convert to TemplateLocation structs
        return locations.map {
            TemplateLocation(id: $0, path: $1)
        }
    }
}
