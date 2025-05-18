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

    /// A parser responsible for processing front matter data.
    let markdownParser: MarkdownParser

    /// A file manager instance for handling file operations.
    let fileManager: FileManagerKit

    /// The logger instance
    let logger: Logger

    public init(
        locations: SourceLocations,
        markdownParser: MarkdownParser,
        fileManager: FileManagerKit,
        logger: Logger = .subsystem("raw-content-loader")
    ) {
        self.locations = locations
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
    func load() throws -> [RawContent] {
        logger.debug(
            "Loading raw contents at: `\(locations.contentsUrl.absoluteString)`"
        )

        var items: [RawContent] = []
        //        for location in locations {
        //            let item = try resolveItem(location)
        //            items.append(item)
        //        }

        return items
    }

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
}

extension RawContentLoader {

    /// Recursively traverses the content directory to locate index-based content definitions.
    ///
    /// - Parameters:
    ///   - contentsUrl: The base directory for contents.
    ///   - slug: The accumulated slug segments (used to form the output slug).
    ///   - path: The accumulated path segments (used to navigate the file system).
    /// - Returns: A list of discovered `RawContentLocation` objects.
    func locateRawContentsOrigins(
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

    private func hasIndex(
        at url: URL
    ) -> Bool {
        !fileManager.find(
            name: "index",
            extensions: ["yml", "yaml", "md", "markdown"],
            at: url
        )
        .isEmpty
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

    func locateAssets(at url: URL) -> [String] {
        fileManager.find(
            recursively: true,
            at: url
        )
    }

    func resolveItem(_ location: Origin) throws -> RawContent {
        var frontMatter: [String: AnyCodable] = [:]
        var markdown: String?
        var path: String?
        var modificationDate: Date?

        //        typealias Resolver = (String) throws -> (
        //            frontMatter: [String: AnyCodable],
        //            markdown: String
        //        )
        //
        //        let orderedPathResolvers:
        //            [(
        //                primaryPath: String?,
        //                fallbackPath: String?,
        //                resolver: Resolver,
        //                isMarkdown: Bool
        //            )] = [
        //                //                (location.markdown, location.md, resolveMarkdown, true),
        //                (location.yaml, location.yml, resolveYaml, false)
        //            ]
        //
        //        for (
        //            primaryPath,
        //            fallbackPath,
        //            resolver,
        //            isMarkdown
        //        ) in orderedPathResolvers {
        //            if let filePath = primaryPath ?? fallbackPath {
        //                do {
        //                    let result = try resolver(filePath)
        //
        //                    frontMatter = frontMatter.recursivelyMerged(
        //                        with: result.frontMatter
        //                    )
        //
        //                    /// Set contents if its a md resolver
        //                    if isMarkdown {
        //                        markdown = result.markdown
        //                    }
        //                    /// Set path if its a md resolver or a yml resolver but there is no path yet
        //                    if isMarkdown || path == nil {
        //                        path = filePath
        //                    }
        //                    /// Set modification date if there is no date yet (either md or yml) or if its more recent
        //                    let url = url.appendingPathComponent(path ?? "")
        //                    if let existingDate = modificationDate {
        //                        modificationDate = max(
        //                            existingDate,
        //                            try fileManager.modificationDate(at: url)
        //                        )
        //                    }
        //                    else {
        //                        modificationDate = try fileManager.modificationDate(
        //                            at: url
        //                        )
        //                    }
        //                }
        //                catch ToucanDecoderError.decoding(_, _) {
        //                    throw Error.invalidFrontMatter(path: filePath)
        //                }
        //            }
        //        }

        let url = locations.contentsUrl.appendingPathComponent(path ?? "")

        let assetsPath = locations.config.contents.assets.path
        let assetsUrl =
            url
            .deletingLastPathComponent()
            .appending(path: assetsPath)

        let assetLocations = fileManager.find(
            recursively: true,
            at: assetsUrl
        )

        return RawContent(
            origin: .init(
                path: path ?? "",
                slug: location.slug
            ),
            markdown: .init(
                frontMatter: frontMatter,
                contents: markdown ?? ""
            ),
            lastModificationDate: (modificationDate ?? Date())
                .timeIntervalSince1970,
            assets: assetLocations
        )
    }

    func loadItem(at url: URL) throws -> String {
        try String(contentsOf: url, encoding: .utf8)
    }
}

extension RawContentLoader {

    func resolveMarkdown(
        at path: String
    ) throws -> Markdown {
        let url = locations.contentsUrl.appendingPathComponent(path)
        let markdown = try loadItem(at: url)
        return try markdownParser.parse(markdown)
    }

    func resolveYaml(
        at path: String
    ) throws -> (frontMatter: [String: AnyCodable], markdown: String) {
        let url = locations.contentsUrl.appendingPathComponent(path)
        let rawContents = try loadItem(at: url)
        return (
            frontMatter: try markdownParser.decoder.decode(
                [String: AnyCodable].self,
                from: rawContents.data(using: .utf8)!
            ),
            markdown: ""
        )
    }
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
