//
//  RawContentLoader.swift
//  Toucan
//
//  Created by Viasz-Kádi Ferenc on 2025. 03. 03..
//

import FileManagerKit
import Foundation
import Logging
import ToucanCore
import ToucanSerialization

/// A utility structure responsible for loading and parsing raw content files
public struct RawContentLoader {

    /// Source configuration.
    let contentsURL: URL

    /// The relative path where asset files are expected to be found.
    let assetsPath: String

    /// Decoder used to decode YAML files.
    let decoder: ToucanYAMLDecoder

    /// A parser responsible for processing front matter data.
    let markdownParser: MarkdownParser

    /// A file manager instance for handling file operations.
    let fileManager: FileManagerKit

    /// The logger instance
    let logger: Logger

    /// Creates a new instance of `RawContentLoader` with the provided dependencies.
    ///
    /// - Parameters:
    ///   - contentsURL: The base URL where content files are located.
    ///   - assetsPath: The relative path to the directory containing asset files.
    ///   - decoder: A decoder used to parse YAML content from files.
    ///   - markdownParser: A parser used to extract front matter and body from Markdown files.
    ///   - fileManager: An instance responsible for file system operations.
    ///   - logger: A logger instance used for recording diagnostic messages. Defaults to a subsystem-specific logger.
    public init(
        contentsURL: URL,
        assetsPath: String,
        decoder: ToucanYAMLDecoder,
        markdownParser: MarkdownParser,
        fileManager: FileManagerKit,
        logger: Logger = .subsystem("raw-content-loader")
    ) {
        self.contentsURL = contentsURL
        self.assetsPath = assetsPath
        self.decoder = decoder
        self.markdownParser = markdownParser
        self.fileManager = fileManager
        self.logger = logger
    }

    /// Recursively finds all assets in the given directory.
    ///
    /// - Parameter url: The URL of the directory to search.
    /// - Returns: A sorted list of relative asset file paths.
    private func locateAssets(
        at url: URL
    ) -> [String] {
        fileManager.find(recursively: true, at: url).sorted()
    }

    /// Recursively traverses the content directory to locate index-based content definitions.
    ///
    /// - Parameters:
    ///   - contentsURL: The base directory for contents.
    ///   - slug: The accumulated slug segments (used to form the output slug).
    ///   - path: The accumulated path segments (used to navigate the file system).
    /// - Returns: A list of discovered `RawContentLocation` objects.
    private func locateRawContentsOrigins(
        at contentsURL: URL,
        slug: [String] = [],
        path: [String] = []
    ) -> [Origin] {
        var result: [Origin] = []
        let currentPath = Path(path.joined(separator: "/"))
        let currentSlug = Path(slug.joined(separator: "/"))
            .trimmingBracketsContent()
        let currentURL = contentsURL.appendingPathIfPresent(currentPath.value)

        logger.trace(
            "Trying to locate raw content item.",
            metadata: [
                "contentsURL": .string(contentsURL.absoluteString),
                "path": .string(currentPath.value),
                "slug": .string(currentSlug),
            ]
        )

        if hasIndex(at: currentURL) {
            let origin = Origin(
                path: currentPath,
                slug: currentSlug
            )
            logger.debug(
                "Raw content item found with index.",
                metadata: [
                    "contentsURL": .string(contentsURL.absoluteString),
                    "path": .string(currentPath.value),
                    "slug": .string(currentSlug),
                ]
            )
            result.append(origin)
        }

        let list = fileManager.listDirectory(at: currentURL)
        for item in list {
            var newSlug = slug
            let newPath = path + [item]
            let childURL = currentURL.appendingPathIfPresent(item)

            if !hasNoIndex(item: item, at: childURL) {
                logger.trace(
                    "Raw content item has no index file or bracket.",
                    metadata: [
                        "contentsURL": .string(contentsURL.absoluteString),
                        "path": .string(currentPath.value),
                        "slug": .string(currentSlug),
                    ]
                )
                newSlug += [item]
            }

            result += locateRawContentsOrigins(
                at: contentsURL,
                slug: newSlug,
                path: newPath
            )
        }
        return result
    }

    // MARK: - index helpers

    /// Finds index files within a directory.
    ///
    /// - Parameter url: The directory URL to search in.
    /// - Returns: A list of index filenames matching supported extensions.
    private func getIndexes(
        at url: URL
    ) -> [String] {
        fileManager.find(
            name: "index",
            extensions: ["yaml", "yml", "markdown", "md"],
            at: url
        )
    }

    /// Checks whether a given directory contains index files.
    ///
    /// - Parameter url: The directory URL to check.
    /// - Returns: `true` if index files exist, `false` otherwise.
    private func hasIndex(
        at url: URL
    ) -> Bool {
        !getIndexes(at: url).isEmpty
    }

    /// Determines if a directory should be excluded based on a noindex marker or name brackets.
    ///
    /// - Parameters:
    ///   - item: The name of the directory.
    ///   - url: The URL of the directory.
    /// - Returns: `true` if the directory should be skipped, `false` otherwise.
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

    /// Loads the contents of a file as a UTF-8 string.
    ///
    /// - Parameter url: The URL of the file to read.
    /// - Returns: The file content as a string.
    /// - Throws: An error if the file cannot be read.
    private func loadContentsOfFile(
        at url: URL
    ) throws -> String {
        try String(contentsOf: url, encoding: .utf8)
    }

    /// Loads and parses a Markdown file, extracting front matter and content.
    ///
    /// - Parameter url: The URL of the Markdown file.
    /// - Returns: A `Markdown` object with parsed content.
    /// - Throws: An error if the file cannot be read or parsed.
    private func loadMarkdownFile(
        at url: URL
    ) throws -> Markdown {
        let rawMarkdown = try loadContentsOfFile(at: url)
        return try markdownParser.parse(rawMarkdown)
    }

    /// Loads and decodes a YAML file into a dictionary.
    ///
    /// - Parameter url: The URL of the YAML file.
    /// - Returns: A dictionary of key-value pairs from the YAML content.
    /// - Throws: An error if the file cannot be read or decoded.
    private func loadYAMLFile(
        at url: URL
    ) throws -> [String: AnyCodable] {
        let rawContents = try loadContentsOfFile(at: url)
        return try decoder.decode([String: AnyCodable].self, from: rawContents)
    }

    // MARK: - locate

    /// Locates all raw content entries under a specified base URL.
    ///
    /// Each entry is derived from a folder containing one or more valid index files (Markdown/YAML).
    /// Subdirectories marked with `noindex.yaml|yml` are skipped.
    ///
    /// - Returns: A list of `Origin` objects, sorted by slug.
    func locateOrigins() -> [Origin] {
        locateRawContentsOrigins(
            at: contentsURL
        )
        .sorted { $0.slug < $1.slug }
    }

    /// Loads a single raw content item from the specified origin.
    ///
    /// - Parameter origin: The origin metadata from which to load the content.
    /// - Returns: A populated `RawContent` instance.
    /// - Throws: An error if the content cannot be loaded or parsed.
    func loadRawContent(
        at origin: Origin
    ) throws -> RawContent {
        var frontMatter: [String: AnyCodable] = [:]
        var contents = ""
        var lastModificationDate: Date?

        let currentURL = contentsURL.appendingPathIfPresent(
            origin.path.value
        )

        let indexFiles = getIndexes(at: currentURL).sorted()

        for indexFile in indexFiles {
            let indexURL = currentURL.appendingPathIfPresent(indexFile)

            if let existingDate = lastModificationDate {
                lastModificationDate = try max(
                    existingDate,
                    fileManager.modificationDate(at: indexURL)
                )
            }
            else {
                lastModificationDate = try fileManager.modificationDate(
                    at: indexURL
                )
            }

            switch true {
            case indexFile.hasSuffix("markdown"),
                indexFile.hasSuffix("md"):
                logger.trace(
                    "Loading index Markdown file",
                    metadata: [
                        "path": .string(origin.path.value),
                        "slug": .string(origin.slug),
                        "file": .string(indexFile),
                    ]
                )

                let markdown = try loadMarkdownFile(at: indexURL)
                frontMatter = frontMatter.recursivelyMerged(
                    with: markdown.frontMatter
                )
                contents = markdown.contents
            case indexFile.hasSuffix("yaml"),
                indexFile.hasSuffix("yml"):
                logger.trace(
                    "Loading index YAML file",
                    metadata: [
                        "path": .string(origin.path.value),
                        "slug": .string(origin.slug),
                        "file": .string(indexFile),
                    ]
                )

                let yaml = try loadYAMLFile(at: indexURL)
                frontMatter = frontMatter.recursivelyMerged(with: yaml)
            default:
                logger.warning(
                    "The content has no index file.",
                    metadata: [
                        "path": .string(origin.path.value),
                        "slug": .string(origin.slug),
                    ]
                )
                continue
            }
        }

        let modificationDate = lastModificationDate ?? Date()
        let assetsURL = currentURL.appendingPathIfPresent(assetsPath)
        let assets = locateAssets(at: assetsURL)

        return RawContent(
            origin: origin,
            markdown: .init(
                frontMatter: frontMatter,
                contents: contents
            ),
            lastModificationDate: modificationDate.timeIntervalSince1970,
            assetsPath: assetsPath,
            assets: assets.sorted()
        )
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
                "path": .string(contentsURL.path())
            ]
        )
        let origins = locateOrigins()

        return try origins.map {
            return try loadRawContent(at: $0)
        }
    }
}
