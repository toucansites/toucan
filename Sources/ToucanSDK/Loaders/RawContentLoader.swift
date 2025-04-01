//
//  File.swift
//  toucan
//
//  Created by Viasz-Kádi Ferenc on 2025. 03. 03..
//

import Foundation
import Logging
import ToucanModels
import ToucanFileSystem
import ToucanSource
import FileManagerKit

struct RawContentLoader {

    /// The URL of the source files.
    let url: URL

    /// Content file paths
    let locations: [RawContentLocation]

    /// Source configuration.
    let sourceConfig: SourceConfig

    /// A parser responsible for processing front matter data.
    let frontMatterParser: FrontMatterParser

    /// A file manager instance for handling file operations.
    let fileManager: FileManagerKit

    /// The logger instance
    let logger: Logger

    // baseUrl for image asset resolve
    let baseUrl: String

    /// Loads the configuration.
    ///
    /// This function attempts to load a configuration file from a specified URL, parses the file contents,
    /// and returns a `Config` object based on the file's data. If the file is missing or cannot be parsed,
    /// an appropriate error is thrown.
    ///
    /// - Returns: A `Config` object representing the loaded configuration.
    /// - Throws: An error if the configuration file is missing or if its contents cannot be decoded.
    func load() throws -> [RawContent] {
        logger.debug("Loading raw contents at: `\(url.absoluteString)`.")

        var items: [RawContent] = []
        for location in locations {
            let item = try resolveItem(location)
            items.append(item)
        }

        return items
    }
}

private extension RawContentLoader {

    func resolveItem(_ location: RawContentLocation) throws -> RawContent {
        var frontMatter: [String: AnyCodable] = [:]
        var markdown: String?
        var path: String?
        var modificationDate: Date?

        typealias Resolver = (String) throws -> (
            frontMatter: [String: AnyCodable],
            markdown: String
        )

        let orderedPathResolvers: [
            (primaryPath: String?, fallbackPath: String?, resolver: Resolver, isMarkdown: Bool)
        ] = [
            (location.markdown, location.md, resolveMarkdown, true),
            (location.yaml, location.yml, resolveYaml, false)
        ]

        for (primaryPath, fallbackPath, resolver, isMarkdown) in orderedPathResolvers {
            if let filePath = primaryPath ?? fallbackPath {
                let result = try resolver(filePath)
                frontMatter = frontMatter.recursivelyMerged(with: result.frontMatter)
                
                /// Set contents if its a md resolver
                if isMarkdown {
                    markdown = result.markdown
                }
                /// Set path if its a md resolver or a yml resolver but there is no path yet
                if isMarkdown || path == nil {
                    path = filePath
                }
                /// Set modification date if there is no date yet (either md or yml) or if its more recent
                let url = url.appendingPathComponent(path ?? "")
                if let existingDate = modificationDate {
                    modificationDate = max(
                        existingDate,
                        try fileManager.modificationDate(at: url)
                    )
                } else {
                    modificationDate = try fileManager.modificationDate(at: url)
                }
            }
        }
        
        let url = url.appendingPathComponent(path ?? "")

        let assetLocator = AssetLocator(fileManager: fileManager)
        let assetsPath = sourceConfig.config.contents.assets.path
        let assetsUrl = url.deletingLastPathComponent().appending(
            path: assetsPath
        )
        let assetLocations = assetLocator.locate(at: assetsUrl)
        
        frontMatter["image"] = .init(
            resolveImage(
                frontMatter: frontMatter,
                assetsPath: assetsPath,
                assetLocations: assetLocations,
                slug: location.slug
            )
        )

        //         TODO: implement asset properties, use them where: frontMatter. / frontMatter[
        //        see: https://www.notion.so/binarybirds/Asset-properties-1b7947db00a680cc8bedcdd644c26698?pvs=4
        //
        //        let encoder: ToucanEncoder = ToucanYAMLEncoder()
        //        let decoder: ToucanDecoder = ToucanYAMLDecoder()
        //
        //        let rawReservedFrontMatter = try encoder.encode(frontMatter)
        //        let reservedFrontMatter = try decoder.decode(
        //            ReservedFrontMatter.self,
        //            from: rawReservedFrontMatter.dataValue()
        //        )
        //
        //        var assets: [String] = []
        //
        //        if let assetProperties = reservedFrontMatter.assetProperties {
        //            for assetProperty in assetProperties {
        //                switch assetProperty.action {
        //                case .add:
        //                    let resolvedPath = assetProperty.resolvedPath(
        //                        baseUrl: baseUrl,
        //                        assetsPath: assetsPath,
        //                        slug: origin.slug
        //                    )
        //                    assets.append(resolvedPath)
        //                    print(resolvedPath)
        //                case .set:
        //                    assets.removeAll()
        //
        //                    let resolvedPath = assetProperty.resolvedPath(
        //                        baseUrl: baseUrl,
        //                        assetsPath: assetsPath,
        //                        slug: origin.slug
        //                    )
        //                    assets.append(resolvedPath)
        //                    print(resolvedPath)
        //                }
        //            }
        //        }

        // resolve css context
        var css: [String] = []
        if let config = frontMatter["css"]?.arrayValue(as: String.self) {
            css = config.map {
                $0.resolveAsset(
                    baseUrl: baseUrl,
                    assetsPath: assetsPath,
                    slug: location.slug
                )
            }
        }

        if assetLocations.contains("style.css") {
            css.append(
                "./\(assetsPath)/style.css"
                    .resolveAsset(
                        baseUrl: baseUrl,
                        assetsPath: assetsPath,
                        slug: location.slug
                    )
            )
        }

        frontMatter["css"] = .init(Array(Set(css)))

        // resolve js context
        var js: [String] = []
        if let config = frontMatter["js"]?.arrayValue(as: String.self) {
            js = config.map {
                $0.resolveAsset(
                    baseUrl: baseUrl,
                    assetsPath: assetsPath,
                    slug: location.slug
                )
            }
        }

        if assetLocations.contains("main.js") {
            js.append(
                "./\(assetsPath)/main.js"
                    .resolveAsset(
                        baseUrl: baseUrl,
                        assetsPath: assetsPath,
                        slug: location.slug
                    )
            )
        }

        frontMatter["js"] = .init(Array(Set(js)))

        return RawContent(
            origin: .init(path: path ?? "", slug: location.slug),
            frontMatter: frontMatter,
            markdown: markdown ?? "",
            lastModificationDate: (modificationDate ?? Date()).timeIntervalSince1970,
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
    ) throws -> (frontMatter: [String: AnyCodable], markdown: String) {
        let url = url.appendingPathComponent(path)
        let rawContents = try loadItem(at: url)
        return (
            frontMatter: try frontMatterParser.parse(rawContents),
            markdown: rawContents.dropFrontMatter()
        )
    }
    
    func resolveYaml(
        at path: String
    ) throws -> (frontMatter: [String: AnyCodable], markdown: String) {
        let url = url.appendingPathComponent(path)
        let rawContents = try loadItem(at: url)
        return (
            frontMatter: try frontMatterParser.decoder.decode(
                [String: AnyCodable].self,
                from: rawContents.dataValue()
            ),
            markdown: ""
        )
    }

    func resolveImage(
        frontMatter: [String: AnyCodable],
        assetsPath: String,
        assetLocations: [String],
        slug: String,
        imageKey: String = "image"
    ) -> String? {
        func resolveCoverImage(fileName: String) -> String {
            return .init(
                "./\(assetsPath)/\(fileName)"
                    .resolveAsset(
                        baseUrl: baseUrl,
                        assetsPath: assetsPath,
                        slug: slug
                    )
            )
        }

        if let imageValue = frontMatter[imageKey]?.stringValue() {
            if imageValue.hasPrefix("/") {
                return .init(
                    baseUrl.appending(imageValue.dropFirst())
                )
            }
            else {
                return .init(
                    imageValue.resolveAsset(
                        baseUrl: baseUrl,
                        assetsPath: assetsPath,
                        slug: slug
                    )
                )
            }
        }
        else if assetLocations.contains("cover.jpg") {
            return resolveCoverImage(fileName: "cover.jpg")
        }
        else if assetLocations.contains("cover.png") {
            return resolveCoverImage(fileName: "cover.png")
        }

        return nil
    }
}

extension AssetProperty {

    func resolvedPath(
        baseUrl: String,
        assetsPath: String,
        slug: String
    ) -> String {
        if resolvePath {
            return "\(file.name).\(file.ext)"
                .resolveAsset(
                    baseUrl: baseUrl,
                    assetsPath: assetsPath,
                    slug: slug
                )
        }
        return "\(file.name).\(file.ext)"
    }
}
