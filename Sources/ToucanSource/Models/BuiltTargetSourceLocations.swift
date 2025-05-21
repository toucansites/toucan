//
//  SourceLocations.swift
//  Toucan
//
//  Created by Viasz-Kádi Ferenc on 2025. 03. 01..
//

import struct Foundation.URL
import Logging
import ToucanCore

/// A computed mapping of project-relative URLs based on the loaded configuration and project root.
public struct BuiltTargetSourceLocations {

    // MARK: - Properties

    public var baseUrl: URL
    public var contentsUrl: URL
    public var siteSettingsURL: URL
    public var siteAssetsUrl: URL
    public var typesUrl: URL
    public var blocksUrl: URL
    public var pipelinesUrl: URL
    public var themesUrl: URL
    public var currentThemeUrl: URL
    public var currentThemeAssetsUrl: URL
    public var currentThemeTemplatesUrl: URL
    public var currentThemeOverridesUrl: URL
    public var currentThemeOverridesAssetsUrl: URL
    public var currentThemeOverridesTemplatesUrl: URL

    // MARK: - Initialization

    public init(
        sourceUrl: URL,
        config: Config
    ) {
        let base = sourceUrl

        let contents =
            base
            .appendingPathIfPresent(config.contents.path)

        let settings =
            base
            .appendingPathIfPresent(config.site.settings.path)
        let assets =
            base
            .appendingPathIfPresent(config.site.assets.path)

        let types =
            base
            .appendingPathIfPresent(config.types.path)
        let blocks =
            base
            .appendingPathIfPresent(config.blocks.path)
        let pipelines =
            base
            .appendingPathIfPresent(config.pipelines.path)
        let themes =
            base
            .appendingPathIfPresent(config.themes.location.path)

        let currentTheme =
            themes
            .appendingPathIfPresent(config.themes.current.path)
        let themeAssets =
            currentTheme
            .appendingPathIfPresent(config.themes.assets.path)
        let themeTemplates =
            currentTheme
            .appendingPathIfPresent(config.themes.templates.path)

        let themeOverrides =
            themes
            .appendingPathIfPresent(config.themes.overrides.path)
            .appendingPathIfPresent(config.themes.current.path)
        let themeOverridesAssets =
            themeOverrides
            .appendingPathIfPresent(config.themes.assets.path)
        let themeOverridesTemplates =
            themeOverrides
            .appendingPathIfPresent(config.themes.templates.path)

        baseUrl = base
        contentsUrl = contents
        siteSettingsURL = settings
        siteAssetsUrl = assets
        typesUrl = types
        blocksUrl = blocks
        pipelinesUrl = pipelines
        themesUrl = themes
        currentThemeUrl = currentTheme
        currentThemeAssetsUrl = themeAssets
        currentThemeTemplatesUrl = themeTemplates
        currentThemeOverridesUrl = themeOverrides
        currentThemeOverridesAssetsUrl = themeOverridesAssets
        currentThemeOverridesTemplatesUrl = themeOverridesTemplates
    }
}

extension BuiltTargetSourceLocations: LoggerMetadataRepresentable {

    public var logMetadata: [String: Logger.MetadataValue] {
        [
            "baseUrl": .string(baseUrl.absoluteString)
        ]
    }
}
