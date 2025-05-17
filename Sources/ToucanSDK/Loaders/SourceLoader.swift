//
//  SourceLoader.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 04. 04..
//

import Foundation
import Logging
import ToucanModels
import ToucanContent
import ToucanFileSystem
import FileManagerKit
import ToucanSerialization

struct SourceLoader {

    let sourceUrl: URL
    let target: Target

    let fileManager: FileManagerKit
    let frontMatterParser: FrontMatterParser

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
    func load() throws -> SourceBundle {

        let config = try loadConfig()

        let sourceConfig = SourceConfig(
            sourceUrl: sourceUrl,
            config: config
        )

        let settings = try loadSettings(
            at: sourceConfig.siteSettingsURL
        )

        logger.trace(
            "Types url: `\(sourceConfig.typesUrl.absoluteString)`"
        )
        logger.trace(
            "Blocks url: `\(sourceConfig.blocksUrl.absoluteString)`"
        )

        logger.trace(
            "Themes location url: `\(sourceConfig.themesUrl.absoluteString)`"
        )
        logger.trace(
            "Current theme url: `\(sourceConfig.currentThemeUrl.absoluteString)`"
        )
        logger.trace(
            "Current theme assets url: `\(sourceConfig.currentThemeAssetsUrl.absoluteString)`"
        )
        logger.trace(
            "Current theme templates url: `\(sourceConfig.currentThemeTemplatesUrl.absoluteString)`"
        )

        logger.trace(
            "Theme override url: `\(sourceConfig.currentThemeOverrideUrl.absoluteString)`"
        )
        logger.trace(
            "Theme override assets url: `\(sourceConfig.currentThemeOverrideAssetsUrl.absoluteString)`"
        )
        logger.trace(
            "Theme override templates url: `\(sourceConfig.currentThemeOverrideTemplatesUrl.absoluteString)`"
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

        let blockDirectives: [MarkdownBlockDirective] = try ObjectLoader(
            url: sourceConfig.blocksUrl,
            locations: fileManager.find(
                extensions: ["yml", "yaml"],
                at: sourceConfig.blocksUrl
            ),
            encoder: encoder,
            decoder: decoder,
            logger: logger
        )
        .load(MarkdownBlockDirective.self)

        logger.debug(
            "Available block directives: `\(blockDirectives.map(\.name).joined(separator: ", "))`"
        )

        // MARK: - RawContents

        let rawContentLocations = RawContentLocator(
            fileManager: fileManager
        )
        .locate(
            at: sourceConfig.contentsUrl
        )
        let rawContentsLoader = RawContentLoader(
            url: sourceConfig.contentsUrl,
            locations: rawContentLocations,
            sourceConfig: sourceConfig,
            frontMatterParser: frontMatterParser,
            fileManager: fileManager,
            logger: logger,
            baseUrl: target.url
        )
        let rawContents = try rawContentsLoader.load()

        // MARK: - Create Contents from RawContents

        let contents: [Content] = try rawContents.compactMap {
            /// If this is slow or overkill we can still use $0.frontMatter["type"], maybe with a Keys enum?
            let rawReservedFrontMatter = try encoder.encode($0.frontMatter)
            let reservedFrontMatter = try decoder.decode(
                ReservedFrontMatter.self,
                from: rawReservedFrontMatter.dataValue()
            )

            let detector = ContentDefinitionDetector(
                definitions: contentDefinitions,
                origin: $0.origin,
                logger: logger
            )

            let contentDefinition = try detector.detect(
                explicitType: reservedFrontMatter.type
            )

            let contentDefinitionConverter = ContentDefinitionConverter(
                contentDefinition: contentDefinition,
                dateFormatter: target.dateFormatter(config.dateFormats.input),
                logger: logger
            )

            return contentDefinitionConverter.convert(rawContent: $0)
        }

        // MARK: - Templates
        #warning("fixme")
        //        let templateLocations = TemplateLocator(
        //            fileManager: fileManager
        //        )
        //        .locate(
        //            at: sourceConfig.currentThemeTemplatesUrl,
        //            overrides: sourceConfig.currentThemeOverrideTemplatesUrl
        //        )
        //        let templateLoader = TemplateLoader(
        //            url: sourceConfig.currentThemeTemplatesUrl,
        //            overridesUrl: sourceConfig.currentThemeOverrideTemplatesUrl,
        //            locations: templateLocations,
        //            logger: logger
        //        )
        //        let templates = try templateLoader.load()

        return .init(
            location: sourceUrl,
            target: target,
            config: config,
            sourceConfig: sourceConfig,
            settings: settings,
            pipelines: pipelines,
            contents: contents,
            blockDirectives: blockDirectives,
            templates: [:],
            baseUrl: target.url
        )
    }
}
