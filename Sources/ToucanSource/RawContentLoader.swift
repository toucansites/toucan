//
//  RawContentLoader.swift
//  Toucan
//
//  Created by Viasz-Kádi Ferenc on 2025. 03. 03..
//

import Foundation
import Logging
import FileManagerKit
import ToucanCore
import ToucanSerialization

fileprivate extension String {

    func trimmingBracketsContent() -> String {
        var result = ""
        var insideBrackets = false

        let decoded = self.removingPercentEncoding ?? self

        for char in decoded {
            if char == "[" {
                insideBrackets = true
            }
            else if char == "]" {
                insideBrackets = false
            }
            else if !insideBrackets {
                result.append(char)
            }
        }
        return result
    }
}

/// A utility structure responsible for loading and parsing raw content files
public struct RawContentLoader {

    /// Represents errors that can occur during the raw content loading process.
    /// - `invalidFrontMatter`: Indicates that the front matter could not be parsed correctly at the specified file path.
    public enum Error: Swift.Error {
        case invalidFrontMatter(path: String)
    }

    /// Source configuration.
    let locations: SourceLocations

    /// Decoder used to decode YAML files.
    let decoder: ToucanYAMLDecoder

    /// A parser responsible for processing front matter data.
    let markdownParser: MarkdownParser

    /// A file manager instance for handling file operations.
    let fileManager: FileManagerKit

    /// The logger instance
    let logger: Logger

    public init(
        locations: SourceLocations,
        decoder: ToucanYAMLDecoder,
        markdownParser: MarkdownParser,
        fileManager: FileManagerKit,
        logger: Logger = .subsystem("raw-content-loader")
    ) {
        self.locations = locations
        self.decoder = decoder
        self.markdownParser = markdownParser
        self.fileManager = fileManager
        self.logger = logger
    }

    /// Loads raw content items from a set of predefined locations.
    ///
    /// This function iterates over a collection of locations, resolves each into a `RawContent` item,
    /// and collects them into an array.
    ///
    /// - Returns: An array of `RawContent` objects representing the loaded items.
    /// - Throws: An error if any of the content items cannot be resolved.
    public func load() throws -> [RawContent] {
        logger.debug(
            "Loading raw contents.",
            metadata: [
                "path": .string(locations.contentsUrl.absoluteString)
            ]
        )
        return try locateOrigins()
            .map {
                try loadRawContent(at: $0)
            }
    }

    // MARK: - locate

    /// Locates all raw content entries under a specified base URL.
    ///
    /// Each entry is derived from a folder containing one or more valid index files (Markdown/YAML).
    /// Subdirectories marked with `noindex.yaml|yml` are skipped.
    ///
    /// - Parameter url: The root content directory to scan.
    /// - Returns: A list of `RawContentLocation` objects, sorted by slug.
    func locateOrigins() -> [Origin] {
        locateRawContentsOrigins(
            at: locations.contentsUrl
        )
        .sorted { $0.slug < $1.slug }
    }

    func loadRawContent(
        at origin: Origin
    ) throws -> RawContent {

        var frontMatter: [String: AnyCodable] = [:]
        var contents: String = ""
        var lastModificationDate: Date?

        let contentUrl = locations.contentsUrl.appendingPathIfPresent(
            origin.path
        )

        let indexFiles = getIndexes(at: contentUrl).sorted()

        for indexFile in indexFiles {

            let indexUrl = contentUrl.appendingPathIfPresent(indexFile)

            if let existingDate = lastModificationDate {
                lastModificationDate = max(
                    existingDate,
                    try fileManager.modificationDate(at: indexUrl)
                )
            }
            else {
                lastModificationDate = try fileManager.modificationDate(
                    at: indexUrl
                )
            }

            switch true {
            case indexFile.hasSuffix("markdown"),
                indexFile.hasSuffix("md"):
                logger.trace(
                    "Loading index Markdown file",
                    metadata: [
                        "path": .string(origin.path),
                        "slug": .string(origin.slug),
                        "file": .string(indexFile),
                    ]
                )

                let markdown = try loadMarkdownFile(at: indexUrl)
                frontMatter = frontMatter.recursivelyMerged(
                    with: markdown.frontMatter
                )
                contents = markdown.contents
            case indexFile.hasSuffix("yaml"),
                indexFile.hasSuffix("yml"):
                logger.trace(
                    "Loading index YAML file",
                    metadata: [
                        "path": .string(origin.path),
                        "slug": .string(origin.slug),
                        "file": .string(indexFile),
                    ]
                )

                let yaml = try loadYAMLFile(at: indexUrl)
                frontMatter = frontMatter.recursivelyMerged(with: yaml)
            default:
                logger.warning(
                    "The content has no index file.",
                    metadata: [
                        "path": .string(origin.path),
                        "slug": .string(origin.slug),
                    ]
                )
                continue
            }
        }

        let modificationDate = lastModificationDate ?? Date()
        let assetsPath = locations.config.contents.assets.path
        let assetsUrl = contentUrl.appendingPathIfPresent(assetsPath)
        let assets = locateAssets(at: assetsUrl)

        return RawContent(
            origin: origin,
            markdown: .init(
                frontMatter: frontMatter,
                contents: contents
            ),
            lastModificationDate: modificationDate.timeIntervalSince1970,
            assets: assets.sorted()
        )
    }

    private func locateAssets(at url: URL) -> [String] {
        fileManager.find(recursively: true, at: url).sorted()
    }

    /// Recursively traverses the content directory to locate index-based content definitions.
    ///
    /// - Parameters:
    ///   - contentsUrl: The base directory for contents.
    ///   - slug: The accumulated slug segments (used to form the output slug).
    ///   - path: The accumulated path segments (used to navigate the file system).
    /// - Returns: A list of discovered `RawContentLocation` objects.
    private func locateRawContentsOrigins(
        at contentsUrl: URL,
        slug: [String] = [],
        path: [String] = []
    ) -> [Origin] {
        var result: [Origin] = []
        let currentPath = path.joined(separator: "/")
        let currentSlug = slug.joined(separator: "/").trimmingBracketsContent()
        let currentUrl = contentsUrl.appendingPathIfPresent(currentPath)

        logger.trace(
            "Trying to locate raw content item.",
            metadata: [
                "contentsURL": .string(contentsUrl.absoluteString),
                "path": .string(currentPath),
                "slug": .string(currentSlug),
            ]
        )

        if hasIndex(at: currentUrl) {
            let origin = Origin(
                path: currentPath,
                slug: currentSlug
            )
            logger.debug(
                "Raw content item found with index.",
                metadata: [
                    "contentsURL": .string(contentsUrl.absoluteString),
                    "path": .string(currentPath),
                    "slug": .string(currentSlug),
                ]
            )
            result.append(origin)
        }

        let list = fileManager.listDirectory(at: currentUrl)
        for item in list {
            var newSlug = slug
            let newPath = path + [item]
            let childUrl = currentUrl.appendingPathIfPresent(item)

            if !hasNoIndex(item: item, at: childUrl) {
                logger.trace(
                    "Raw content item has no index file or bracket.",
                    metadata: [
                        "contentsURL": .string(contentsUrl.absoluteString),
                        "path": .string(currentPath),
                        "slug": .string(currentSlug),
                    ]
                )
                newSlug += [item]
            }

            result += locateRawContentsOrigins(
                at: contentsUrl,
                slug: newSlug,
                path: newPath
            )
        }
        return result
    }

    // MARK: - index helpers

    private func getIndexes(
        at url: URL
    ) -> [String] {
        fileManager.find(
            name: "index",
            extensions: ["yml", "yaml", "md", "markdown"],
            at: url
        )
    }

    private func hasIndex(
        at url: URL
    ) -> Bool {
        !getIndexes(at: url).isEmpty
    }

    private func hasNoIndex(
        item: String,
        at url: URL
    ) -> Bool {
        // Skip folders that have a noindex file or bracket marker
        let noindexFilePaths = fileManager.find(
            name: "noindex",
            extensions: ["yaml", "yml"],
            at: url
        )
        let decodedItem = item.removingPercentEncoding ?? ""
        let skip = decodedItem.hasPrefix("[") && decodedItem.hasSuffix("]")

        return skip || !noindexFilePaths.isEmpty
    }

    // MARK: - file load

    private func loadContentsOfFile(
        at url: URL
    ) throws -> String {
        try String(contentsOf: url, encoding: .utf8)
    }

    private func loadMarkdownFile(
        at url: URL
    ) throws -> Markdown {
        let rawMarkdown = try loadContentsOfFile(at: url)
        return try markdownParser.parse(rawMarkdown)
    }

    private func loadYAMLFile(
        at url: URL
    ) throws -> [String: AnyCodable] {
        let rawContents = try loadContentsOfFile(at: url)
        return try decoder.decode([String: AnyCodable].self, from: rawContents)
    }

}

extension RawContentLoader {

    //
    //    func resolveImage(
    //        frontMatter: [String: AnyCodable],
    //        assetsPath: String,
    //        assetLocations: [String],
    //        slug: Slug,
    //        imageKey: String = "image"
    //    ) -> String? {
    //
    //        if let imageValue = frontMatter[imageKey]?.stringValue() {
    //            if imageValue.hasPrefix("/") {
    //                return .init(
    //                    "\(baseUrl)\(baseUrl.suffixForPath())\(imageValue.dropFirst())"
    //                )
    //            }
    //            else {
    //                return .init(
    //                    imageValue.resolveAsset(
    //                        baseUrl: baseUrl,
    //                        assetsPath: assetsPath,
    //                        slug: slug.value
    //                    )
    //                )
    //            }
    //        }
    //
    //        return nil
    //    }
    //
}
