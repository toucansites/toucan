//
//  RawContentLocator.swift
//  Toucan
//
//  Created by Binary Birds on 2025. 04. 17..

import Foundation
import FileManagerKit
import ToucanModels

/// Locates raw content files within a directory structure, identifying supported index files
/// and skipping directories that are explicitly marked as excluded (via `noindex.yml` or `noindex.yaml`).
public struct RawContentLocator {

    /// Underlying file system abstraction.
    private let fileManager: FileManagerKit

    /// Filename for index and noindex markers.
    private let indexName = "index"
    private let noindexName = "noindex"

    // MARK: - Initialization

    /// Initializes the locator with a given file manager.
    ///
    /// - Parameter fileManager: File system handler used for discovery.
    public init(fileManager: FileManagerKit) {
        self.fileManager = fileManager
    }

    // MARK: - Public API

    /// Locates all raw content entries under a specified base URL.
    ///
    /// Each entry is derived from a folder containing one or more valid index files (Markdown/YAML).
    /// Subdirectories marked with `noindex.yaml|yml` are skipped.
    ///
    /// - Parameter url: The root content directory to scan.
    /// - Returns: A list of `RawContentLocation` objects, sorted by slug.
    public func locate(at url: URL) -> [RawContentLocation] {
        locateRawContents(at: url).sorted { $0.slug < $1.slug }
    }
}

private extension RawContentLocator {

    /// Recursively traverses the content directory to locate index-based content definitions.
    ///
    /// - Parameters:
    ///   - contentsUrl: The base directory for contents.
    ///   - slug: The accumulated slug segments (used to form the output slug).
    ///   - path: The accumulated path segments (used to navigate the file system).
    /// - Returns: A list of discovered `RawContentLocation` objects.
    func locateRawContents(
        at contentsUrl: URL,
        slug: [String] = [],
        path: [String] = []
    ) -> [RawContentLocation] {
        var result: [RawContentLocation] = []

        let p = path.joined(separator: "/")
        var url = contentsUrl
        if !p.isEmpty {
            url = url.appendingPathComponent(p)
        }

        func join(_ pathComponents: String...) -> String {
            pathComponents.filter {
                !$0.isEmpty
            }
            .joined(separator: "/")
        }

        // Attempt to locate index files in the current folder
        var rawContentLocation = RawContentLocation(
            slug: slug.joined(separator: "/").trimmingBracketsContent()
        )

        if let value =
            fileManager.find(
                name: indexName,
                extensions: ["markdown"],
                at: url
            )
            .first
        {
            rawContentLocation.markdown = join(p, value)
        }
        if let value =
            fileManager.find(
                name: indexName,
                extensions: ["md"],
                at: url
            )
            .first
        {
            rawContentLocation.md = join(p, value)
        }
        if let value =
            fileManager.find(
                name: indexName,
                extensions: ["yaml"],
                at: url
            )
            .first
        {
            rawContentLocation.yaml = join(p, value)
        }
        if let value =
            fileManager.find(
                name: indexName,
                extensions: ["yml"],
                at: url
            )
            .first
        {
            rawContentLocation.yml = join(p, value)
        }

        if !rawContentLocation.isEmpty {
            result.append(rawContentLocation)
        }

        // Recursively explore subfolders
        let list = fileManager.listDirectory(at: url)
        for item in list {
            var newSlug = slug
            let childUrl = url.appendingPathComponent(item)

            // Skip folders that have a noindex marker
            let noindexFilePaths = fileManager.find(
                name: noindexName,
                extensions: ["yaml", "yml"],
                at: childUrl
            )
            let decodedItem = item.removingPercentEncoding ?? ""
            let skip = decodedItem.hasPrefix("[") && decodedItem.hasSuffix("]")

            if noindexFilePaths.isEmpty && !skip {
                newSlug += [item]
            }

            let newPath = path + [item]
            result += locateRawContents(
                at: contentsUrl,
                slug: newSlug,
                path: newPath
            )
        }
        return result
    }
}
