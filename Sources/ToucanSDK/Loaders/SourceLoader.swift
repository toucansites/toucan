//
//  File.swift
//
//
//  Created by Tibor Bodecs on 27/06/2024.
//

import Foundation
import Logging
import ToucanModels
import ToucanSource
import ToucanFileSystem
import FileManagerKit

struct SourceLoader {

    let sourceUrl: URL
    let baseUrl: String?

    let fileManager: FileManagerKit
    let frontMatterParser: FrontMatterParser

    let encoder: ToucanEncoder
    let decoder: ToucanDecoder

    let logger: Logger

    /// Loads and processes source content from the specified source URL.
    /// This function retrieves configuration, settings, content definitions, block directives,
    /// and raw contents, then transforms them into structured content.
    ///
    /// - Returns: A `SourceBundle` containing the loaded and processed data.
    /// - Throws: An error if any of the loading operations fail.
    func load() throws -> SourceBundle {

        // MARK: - Config

        let configLocator = FileLocator(
            fileManager: fileManager,
            name: "config",
            extensions: ["yml", "yaml"]
        )
        let configLocations = configLocator.locate(at: sourceUrl)

        let configLoader = ConfigLoader(
            url: sourceUrl,
            locations: configLocations,
            encoder: encoder,
            decoder: decoder,
            logger: logger
        )
        let config = try configLoader.load()

        // MARK: - Source URLs

        let sourceConfig = SourceConfig(sourceUrl: sourceUrl, config: config)

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
            "Current theme types url: `\(sourceConfig.currentThemeTypesUrl.absoluteString)`"
        )
        logger.trace(
            "Current theme blocks url: `\(sourceConfig.currentThemeBlocksUrl.absoluteString)`"
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
        logger.trace(
            "Theme override types url: `\(sourceConfig.currentThemeOverrideTypesUrl.absoluteString)`"
        )
        logger.trace(
            "Current override blocks url: `\(sourceConfig.currentThemeOverrideBlocksUrl.absoluteString)`"
        )

        // MARK: - Settings

        let settingsLocator = FileLocator(
            fileManager: fileManager,
            name: "index",
            extensions: ["yml", "yaml"]
        )
        let settingsLocations = settingsLocator.locate(
            at: sourceConfig.contentsUrl
        )

        let settingsLoader = SettingsLoader(
            url: sourceConfig.contentsUrl,
            baseUrl: baseUrl,
            locations: settingsLocations,
            encoder: encoder,
            decoder: decoder,
            logger: logger
        )
        let settings = try settingsLoader.load()

        // MARK: - Pipelines

        let pipelineLocator = FileLocator(
            fileManager: fileManager,
            extensions: ["yml", "yaml"]
        )
        let pipelineLocations = pipelineLocator.locate(
            at: sourceConfig.pipelinesUrl
        )

        let pipelineLoader = PipelineLoader(
            url: sourceConfig.pipelinesUrl,
            locations: pipelineLocations,
            decoder: decoder,
            logger: logger
        )
        let pipelines = try pipelineLoader.load()

        // MARK: - Content definitions

        let yamlFileLocator = OverrideFileLocator(
            fileManager: fileManager,
            extensions: ["yml", "yaml"]
        )
        let contentDefinitionLocations = yamlFileLocator.locate(
            at: sourceConfig.currentThemeTypesUrl,
            overrides: sourceConfig.currentThemeOverrideTypesUrl
        )

        let contentDefinitionLoader = ContentDefinitionLoader(
            url: sourceConfig.currentThemeTypesUrl,
            overridesUrl: sourceConfig.currentThemeOverrideTypesUrl,
            locations: contentDefinitionLocations,
            decoder: decoder,
            logger: logger
        )
        let contentDefinitions = try contentDefinitionLoader.load()

        // MARK: - Block directives

        let blockDirectivesLocations = yamlFileLocator.locate(
            at: sourceConfig.currentThemeBlocksUrl,
            overrides: sourceConfig.currentThemeOverrideBlocksUrl
        )

        let blockDirectivesLoader = BlockDirectiveLoader(
            url: sourceConfig.currentThemeBlocksUrl,
            overridesUrl: sourceConfig.currentThemeOverrideBlocksUrl,
            locations: blockDirectivesLocations,
            decoder: decoder,
            logger: logger
        )
        let blockDirectives = try blockDirectivesLoader.load()

        // MARK: - RawContents

        let rawContentLocations = RawContentLocator(fileManager: fileManager)
            .locate(at: sourceConfig.contentsUrl)

        let rawContentsLoader = RawContentLoader(
            url: sourceConfig.contentsUrl,
            locations: rawContentLocations,
            sourceConfig: sourceConfig,
            frontMatterParser: frontMatterParser,
            fileManager: fileManager,
            logger: logger
        )
        let rawContents = try rawContentsLoader.load()

        // MARK: - Create Contents from RawContents

        let contents: [Content] = try rawContents.compactMap {
            /// If this is slow or overkill we can still use $0.frontMatter["type"], maybe with a Keys enum?
            let rawReservedFromMatter = try encoder.encode($0.frontMatter)
            let reservedFromMatter = try decoder.decode(
                ReservedFrontMatter.self,
                from: rawReservedFromMatter.data(using: .utf8)!
            )

            let detector = ContentDefinitionDetector(
                definitions: contentDefinitions,
                origin: $0.origin,
                logger: logger
            )

            let contentDefinition = try detector.detect(
                explicitType: reservedFromMatter.type
            )

            let contentDefinitionConverter = ContentDefinitionConverter(
                contentDefinition: contentDefinition,
                dateFormatter: config.inputDateFormatter(),
                defaultDateFormat: config.dateFormats.input,
                logger: logger
            )

            return contentDefinitionConverter.convert(rawContent: $0)
        }

        // MARK: - Templates

        let templateLocator = TemplateLocator(fileManager: fileManager)

        let templateLocations = templateLocator.locate(
            at: sourceConfig.currentThemeTemplatesUrl,
            overridesUrl: sourceConfig.currentThemeOverrideTemplatesUrl
        )

        let templateLoader = TemplateLoader(
            url: sourceConfig.currentThemeTemplatesUrl,
            overridesUrl: sourceConfig.currentThemeOverrideTemplatesUrl,
            locations: templateLocations,
            logger: logger
        )
        let templates = try templateLoader.load()

        return .init(
            location: sourceUrl,
            config: config,
            sourceConfig: sourceConfig,
            settings: settings,
            pipelines: pipelines,
            contents: contents,
            blockDirectives: blockDirectives,
            templates: templates
        )
    }
}
