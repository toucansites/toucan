//
//  SourceLoader.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 04. 04..
//

import Foundation
import Logging

import FileManagerKit
import ToucanSerialization

struct SourceLoader {

    let sourceUrl: URL
    let target: Target

    let fileManager: FileManagerKit
    let markdownParser: MarkdownParser

    let encoder: ToucanEncoder
    let decoder: ToucanDecoder

    let logger: Logger

    private func loadConfig() throws -> Config {
        let configUrl = sourceUrl.appending(
            path: target.config
        )
        let config = try ObjectLoader(
            url: configUrl,
            locations: fileManager.find(
                name: "config",
                extensions: ["yaml", "yml"],
                at: configUrl
            ),
            encoder: encoder,
            decoder: decoder,
            logger: logger
        )
        .load(Config.self)

        return config
    }

    private func loadSettings(
        at url: URL
    ) throws -> Settings {

        //        if config.site.settings != nil, settingsLocations.isEmpty {
        //            logger.warning(
        //                "Missing `site.yml` file at url: `\(sourceConfig.siteSettingsURL.absoluteString)`"
        //            )
        //        }

        let settings = try ObjectLoader(
            url: url,
            locations: fileManager.find(
                name: "site",
                extensions: ["yaml", "yml"],
                at: url
            ),
            encoder: encoder,
            decoder: decoder,
            logger: logger
        )
        .load(Settings.self)

        return settings
    }

    /// Loads and processes source content from the specified source URL.
    /// This function retrieves configuration, settings, content definitions, block directives,
    /// and raw contents, then transforms them into structured content.
    ///
    /// - Returns: A `SourceBundle` containing the loaded and processed data.
    /// - Throws: An error if any of the loading operations fail.
    func load() throws -> BuildTargetSource {

        let config = try loadConfig()

        let sourceConfig = SourceLocations(
            sourceUrl: sourceUrl,
            config: config
        )

        let settings = try loadSettings(
            at: sourceConfig.siteSettingsURL
        )

        // MARK: - Pipelines

        let pipelines = try ObjectLoader(
            url: sourceConfig.pipelinesUrl,
            locations: fileManager.find(
                extensions: ["yml", "yaml"],
                at: sourceConfig.pipelinesUrl
            ),
            encoder: encoder,
            decoder: decoder,
            logger: logger
        )
        .load(Pipeline.self)

        // MARK: - Content definitions

        let loadedContentDefinitions = try ObjectLoader(
            url: sourceConfig.typesUrl,
            locations: fileManager.find(
                extensions: ["yml", "yaml"],
                at: sourceConfig.typesUrl
            ),
            encoder: encoder,
            decoder: decoder,
            logger: logger
        )
        .load(ContentDefinition.self)

        let virtualContentDefinitions = pipelines.compactMap {
            $0.definesType ? ContentDefinition(id: $0.id) : nil
        }

        let contentDefinitions =
            loadedContentDefinitions + virtualContentDefinitions

        let contentDefinitionList =
            contentDefinitions
            .map(\.id)
            .joined(separator: ", ")

        logger.debug("Available content types: `\(contentDefinitionList)`")

        // MARK: - Block directives

        let blockDirectives: [Block] = try ObjectLoader(
            url: sourceConfig.blocksUrl,
            locations: fileManager.find(
                extensions: ["yml", "yaml"],
                at: sourceConfig.blocksUrl
            ),
            encoder: encoder,
            decoder: decoder,
            logger: logger
        )
        .load(Block.self)

        logger.debug(
            "Available block directives: `\(blockDirectives.map(\.name).joined(separator: ", "))`"
        )

        // MARK: - RawContents

        //        let rawContentLocations = RawContentLocator(
        //            fileManager: fileManager
        //        )
        //        .locate(
        //            at: sourceConfig.contentsUrl
        //        )
        //        let rawContentsLoader = RawContentLoader(
        //            url: sourceConfig.contentsUrl,
        //            locations: rawContentLocations,
        //            sourceConfig: sourceConfig,
        //            markdownParser: markdownParser,
        //            fileManager: fileManager,
        //            logger: logger,
        //            baseUrl: target.url
        //        )
        //        let rawContents = try rawContentsLoader.load()

        // MARK: - Create Contents from RawContents

        //        let contents: [Content] = try rawContents.compactMap {
        //            /// If this is slow or overkill we can still use $0.frontMatter["type"], maybe with a Keys enum?
        //            let rawReservedFrontMatter = try encoder.encode($0.frontMatter)
        //            let reservedFrontMatter = try decoder.decode(
        //                ReservedFrontMatter.self,
        //                from: rawReservedFrontMatter.data(using: .utf8)!
        //            )
        //
        //            let detector = ContentDefinitionDetector(
        //                definitions: contentDefinitions,
        //                origin: $0.origin,
        //                logger: logger
        //            )
        //
        //            let contentDefinition = try detector.detect(
        //                explicitType: reservedFrontMatter.type
        //            )
        //
        //            let contentDefinitionConverter = ContentDefinitionConverter(
        //                contentDefinition: contentDefinition,
        //                dateFormatter: target.dateFormatter(config.dateFormats.input),
        //                logger: logger
        //            )
        //
        //            return contentDefinitionConverter.convert(rawContent: $0)
        //        }

        return .init(
            location: sourceUrl,
            target: target,
            config: config,
            settings: settings,
            pipelines: pipelines,
            contentDefinitions: contentDefinitions,
            rawContents: [],
            blockDirectives: blockDirectives
        )
    }
}
