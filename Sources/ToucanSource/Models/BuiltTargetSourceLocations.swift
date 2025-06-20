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

    /// The base URL of the source directory.
    public var baseURL: URL
    /// The URL where content files are located.
    public var contentsURL: URL
    /// The URL of the site settings configuration file.
    public var siteSettingsURL: URL
    /// The URL pointing to site-wide asset resources.
    public var siteAssetsURL: URL
    /// The URL containing content type definitions.
    public var typesURL: URL
    /// The URL containing block directive definitions.
    public var blocksURL: URL
    /// The URL pointing to the pipeline configuration files.
    public var pipelinesURL: URL
    /// The URL where template definitions are located.
    public var templatesURL: URL
    /// The URL of the currently active template.
    public var currentTemplateURL: URL
    /// The URL containing assets for the current template.
    public var currentTemplateAssetsURL: URL
    /// The URL pointing to views for the current template.
    public var currentTemplateViewsURL: URL
    /// The URL pointing to the override directory of the current template.
    public var currentTemplateOverridesURL: URL
    /// The URL for overridden assets in the current template.
    public var currentTemplateAssetOverridesURL: URL
    /// The URL for overridden views in the current template.
    public var currentTemplateViewsOverridesURL: URL

    /// Creates a new `BuiltTargetSourceLocations` instance by computing file paths based on the project configuration.
    ///
    /// - Parameters:
    ///   - sourceURL: The base URL of the source directory.
    ///   - config: The configuration object describing relative paths for various components.
    public init(
        sourceURL: URL,
        config: Config
    ) {
        let base = sourceURL

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
        let templates =
            base
            .appendingPathIfPresent(config.templates.location.path)

        let currentTemplate =
            templates
            .appendingPathIfPresent(config.templates.current.path)
        let currentTemplateAssets =
            currentTemplate
            .appendingPathIfPresent(config.templates.assets.path)
        let currentTemplateViews =
            currentTemplate
            .appendingPathIfPresent(config.templates.views.path)

        let currentTemplateOverrides =
            templates
            .appendingPathIfPresent(config.templates.overrides.path)
            .appendingPathIfPresent(config.templates.current.path)
        let currentTemplateAssetOverrides =
            currentTemplateOverrides
            .appendingPathIfPresent(config.templates.assets.path)
        let currentTemplateViewsOverrides =
            currentTemplateOverrides
            .appendingPathIfPresent(config.templates.views.path)

        self.baseURL = base
        self.contentsURL = contents
        self.siteSettingsURL = settings
        self.siteAssetsURL = assets
        self.typesURL = types
        self.blocksURL = blocks
        self.pipelinesURL = pipelines
        self.templatesURL = templates
        self.currentTemplateURL = currentTemplate
        self.currentTemplateAssetsURL = currentTemplateAssets
        self.currentTemplateViewsURL = currentTemplateViews
        self.currentTemplateOverridesURL = currentTemplateOverrides
        self.currentTemplateAssetOverridesURL = currentTemplateAssetOverrides
        self.currentTemplateViewsOverridesURL = currentTemplateViewsOverrides
    }
}

extension BuiltTargetSourceLocations: LoggerMetadataRepresentable {
    /// This metadata can be used to provide additional context in log output.
    public var logMetadata: [String: Logger.MetadataValue] {
        [
            "baseUrl": .string(baseURL.absoluteString)
        ]
    }
}
