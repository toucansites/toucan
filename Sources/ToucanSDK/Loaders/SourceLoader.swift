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
//    let yamlFileLoader: FileLoader
//    let frontMatterParser: FrontMatterParser
    
    let fileManager: FileManagerKit
    let yamlParser: YamlParser
    
    let logger: Logger
    
    // TODO: move locators out of this? pass locations?

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
        
//        let blockDirectiveLoader = BlockDirectiveLoader(
//            sourceConfig: sourceConfig,
//            fileLoader: .yaml,
//            yamlParser: .init(),
//            logger: logger
//        )
//
//        let blockDirectives = try blockDirectiveLoader.load()

        /// Content bundles
        
        let rawContentLocations = RawContentLocator(fileManager: fileManager)
            .locate(at: sourceConfig.contentsUrl)
        
//        let pageBundleLoader = PageBundleLoader(
//            sourceConfig: sourceConfig,
//            contentTypes: contentTypes,
//            fileManager: fileManager,
//            frontMatterParser: frontMatterParser,
//            logger: logger
//        )
//        let pageBundles = try pageBundleLoader.load()

        return .init(
            location: sourceUrl,
            config: config,
            settings: .defaults,    // TODO: parse settings
            pipelines: pipelines,
            contentBundles: []    // TODO: parse content bundles
        )
        
//        return .init(
//            sourceConfig: sourceConfig,
//            contentTypes: contentTypes,
//            blockDirectives: blockDirectives,
//            pageBundles: pageBundles,
//            logger: logger
//        )
    }
}
