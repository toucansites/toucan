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

    //    let baseUrl: String?

    let fileManager: FileManagerKit
    let yamlParser: YamlParser
    let frontMatterParser: FrontMatterParser

    let logger: Logger

    /// load the configuration & the contents of the site source
    func load() throws -> SourceBundle {
        /// Config
        let configLocator = FileLocator(
            fileManager: fileManager,
            name: "config",
            extensions: ["yml", "yaml"]
        )
        let configLocations = configLocator.locate(at: sourceUrl)

        let configLoader = ConfigLoader(
            url: sourceUrl,
            locations: configLocations,
            yamlParser: yamlParser,
            logger: logger
        )
        let config = try configLoader.load()

        //        let siteLoader = SiteLoader(
        //            sourceUrl: sourceUrl,
        //            config: config,
        //            fileLoader: .yaml,
        //            baseUrl: baseUrl,
        //            logger: logger
        //        )
        //        let site = try siteLoader.load()

        /// Source urls

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

        /// Settings

        /// Pipelines

        let pipelineLocator = FileLocator(
            fileManager: fileManager,
            extensions: ["yml", "yaml"]
        )
        let pipelineLocations = pipelineLocator.locate(
            at: sourceConfig.pipelinesUrl
        )

        let pipelineLoader = PipelineLoader(
            url: sourceUrl,
            locations: pipelineLocations,
            yamlParser: yamlParser,
            logger: logger
        )
        let pipelines = try pipelineLoader.load()

        /// Content definitions

        let contentDefinitionLocator = OverrideFileLocator(
            fileManager: fileManager,
            extensions: ["yml", "yaml"]
        )
        let contentDefinitionLocations = contentDefinitionLocator.locate(
            at: sourceConfig.currentThemeTypesUrl,
            overrides: sourceConfig.currentThemeOverrideTypesUrl
        )
        let contentDefinitionLoader = ContentDefinitionLoader(
            url: sourceConfig.currentThemeTypesUrl,
            overridesUrl: sourceConfig.currentThemeOverrideTypesUrl,
            locations: contentDefinitionLocations,
            yamlParser: yamlParser,
            logger: logger
        )
        let contentDefinitions = try contentDefinitionLoader.load()

        /// Block directives
        
        let blockDirectivesLocations = contentDefinitionLocator.locate(
            at: sourceConfig.currentThemeBlocksUrl,
            overrides: sourceConfig.currentThemeOverrideBlocksUrl
        )

        let blockDirectivesLoader = BlockDirectiveLoader(
            url: sourceConfig.currentThemeBlocksUrl,
            overridesUrl: sourceConfig.currentThemeOverrideBlocksUrl,
            locations: blockDirectivesLocations,
            yamlParser: yamlParser,
            logger: logger
        )
        let blockDirectives = try blockDirectivesLoader.load()

        /// Locate RawContents.
        let rawContentLocations = RawContentLocator(fileManager: fileManager)
            .locate(at: sourceConfig.contentsUrl)

        /// Load RawContents.
        let rawContentsLoader = RawContentLoader(
            url: sourceConfig.contentsUrl,
            locations: rawContentLocations,
            sourceConfig: sourceConfig,
            yamlParser: yamlParser,
            frontMatterParser: frontMatterParser,
            fileManager: fileManager,
            logger: logger
        )
        let rawContents = try rawContentsLoader.load()

        /// Create Contents from RawContents.
        let contents: [Content] = try rawContents.compactMap {
            /// If this is slow or overkill we can still use $0.frontMatter["type"], maybe with a Keys enum?
            let rawReservedFromMatter = try yamlParser.encode($0.frontMatter)
            let reservedFromMatter = try yamlParser.decode(
                rawReservedFromMatter,
                as: ReservedFrontMatter.self
            )

            let explicitTypeId = reservedFromMatter.type
            let contentDefinition = $0.origin.detectContentDefinition(
                in: contentDefinitions,
                explicitTypeId: explicitTypeId
            )

            guard let contentDefinition else {
                logger.info("Invalid content type for: \($0.origin.path)")
                return nil
            }

            let contentDefinitionConverter = ContentDefinitionConverter(
                contentDefinition: contentDefinition,
                dateFormatter: config.inputDateFormatter(),
                defaultDateFormat: config.dateFormats.input,
                logger: logger
            )

            return contentDefinitionConverter.convert(rawContent: $0)
        }

        return .init(
            location: sourceUrl,
            config: config,
            settings: .defaults,  // TODO: - parse settings
            pipelines: pipelines,
            contents: contents,
            blockDirectives: blockDirectives
        )
    }
}
