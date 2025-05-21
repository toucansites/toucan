//
//  BuiltTargetSourceLocations.swift
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

    /// The base URL of the source directory.
    public var baseUrl: URL
    /// The URL where content files are located.
    public var contentsUrl: URL
    /// The URL of the site settings configuration file.
    public var siteSettingsURL: URL
    /// The URL pointing to site-wide asset resources.
    public var siteAssetsUrl: URL
    /// The URL containing content type definitions.
    public var typesUrl: URL
    /// The URL containing block directive definitions.
    public var blocksUrl: URL
    /// The URL pointing to the pipeline configuration files.
    public var pipelinesUrl: URL
    /// The URL where theme definitions are located.
    public var themesUrl: URL
    /// The URL of the currently active theme.
    public var currentThemeUrl: URL
    /// The URL containing assets for the current theme.
    public var currentThemeAssetsUrl: URL
    /// The URL pointing to template files of the current theme.
    public var currentThemeTemplatesUrl: URL
    /// The URL pointing to the override directory of the current theme.
    public var currentThemeOverridesUrl: URL
    /// The URL for overridden assets in the current theme.
    public var currentThemeAssetOverridesUrl: URL
    /// The URL for overridden templates in the current theme.
    public var currentThemeTemplateOverridesUrl: URL

    // MARK: - Initialization

    /// Creates a new `BuiltTargetSourceLocations` instance by computing file paths based on the project configuration.
    ///
    /// - Parameters:
    ///   - sourceUrl: The base URL of the source directory.
    ///   - config: The configuration object describing relative paths for various components.
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
        let currentThemeAssets =
            currentTheme
            .appendingPathIfPresent(config.themes.assets.path)
        let currentThemeTemplates =
            currentTheme
            .appendingPathIfPresent(config.themes.templates.path)

        let currentThemeOverrides =
            themes
            .appendingPathIfPresent(config.themes.overrides.path)
            .appendingPathIfPresent(config.themes.current.path)
        let currentThemeAssetOverrides =
            currentThemeOverrides
            .appendingPathIfPresent(config.themes.assets.path)
        let currentThemeTemplateOverrides =
            currentThemeOverrides
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
        currentThemeAssetsUrl = currentThemeAssets
        currentThemeTemplatesUrl = currentThemeTemplates
        currentThemeOverridesUrl = currentThemeOverrides
        currentThemeAssetOverridesUrl = currentThemeAssetOverrides
        currentThemeTemplateOverridesUrl = currentThemeTemplateOverrides
    }
}

extension BuiltTargetSourceLocations: LoggerMetadataRepresentable {

    /// This metadata can be used to provide additional context in log output.
    public var logMetadata: [String: Logger.MetadataValue] {
        [
            "baseUrl": .string(baseUrl.absoluteString)
        ]
    }
}
