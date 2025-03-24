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

struct RawContentLoader {

    /// The URL of the source files.
    let url: URL

    /// Content file paths
    let locations: [Origin]

    /// The type of raw content file.
    let fileType: RawContentFileType

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

import FileManagerKit

private extension RawContentLoader {

    func resolveItem(_ origin: Origin) throws -> RawContent {
        let assetsPath = sourceConfig.config.contents.assets.path
        let url = url.appendingPathComponent(origin.path)
        let rawContents = try loadItem(at: url)

        var frontMatter: [String: AnyCodable]
        let markdown: String

        switch fileType {
        case .markdown:
            frontMatter = try frontMatterParser.parse(rawContents)
            markdown = rawContents.dropFrontMatter()
        case .yaml:
            frontMatter = try frontMatterParser.decoder.decode(
                [String: AnyCodable].self,
                from: rawContents.dataValue()
            )
            markdown = ""
        }

        let imageKey = "image"
        if let imageValue = frontMatter[imageKey]?.stringValue() {
            if imageValue.hasPrefix("/") {
                frontMatter[imageKey] = .init(
                    baseUrl.appending(imageValue.dropFirst())
                )
            }
            else {
                frontMatter[imageKey] = .init(
                    imageValue.resolveAsset(
                        baseUrl: baseUrl,
                        assetsPath: assetsPath,
                        slug: origin.slug
                    )
                )
            }
        }

        //         TODO: - implement asset properties use them where: frontMatter. / frontMatter[
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

        let assetLocator = AssetLocator(fileManager: fileManager)

        let assetsUrl = url.deletingLastPathComponent()
            .appending(path: assetsPath)
        let assetLocations = assetLocator.locate(at: assetsUrl)

        // resolve css context
        var css: [String] = []
        if let config = frontMatter["css"]?.arrayValue(as: String.self) {
            css = config.map {
                $0.resolveAsset(
                    baseUrl: baseUrl,
                    assetsPath: assetsPath,
                    slug: origin.slug
                )
            }
        }

        if assetLocations.contains("style.css") {
            css.append(
                "./\(assetsPath)/style.css"
                    .resolveAsset(
                        baseUrl: baseUrl,
                        assetsPath: assetsPath,
                        slug: origin.slug
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
                    slug: origin.slug
                )
            }
        }

        if assetLocations.contains("main.js") {
            js.append(
                "./\(assetsPath)/main.js"
                    .resolveAsset(
                        baseUrl: baseUrl,
                        assetsPath: assetsPath,
                        slug: origin.slug
                    )
            )
        }

        frontMatter["js"] = .init(Array(Set(js)))

        let modificationDate = try fileManager.modificationDate(at: url)

        return RawContent(
            origin: origin,
            frontMatter: frontMatter,
            markdown: markdown,
            lastModificationDate: modificationDate.timeIntervalSince1970,
            assets: assetLocations
        )
    }

    func loadItem(at url: URL) throws -> String {
        try String(contentsOf: url, encoding: .utf8)
    }
}

extension AssetProperty {

    func resolvedPath(
        baseUrl: String,
        assetsPath: String,
        slug: String
    ) -> String {
        if resolvePath {
            return path.resolveAsset(
                baseUrl: baseUrl,
                assetsPath: assetsPath,
                slug: slug
            )
        }
        return path
    }
}
