//
//  SourceLocations.swift
//  Toucan
//
//  Created by Viasz-Kádi Ferenc on 2025. 03. 01..
//

import Foundation
import ToucanCore

/// A computed mapping of project-relative URLs based on the loaded configuration and project root.
public struct SourceLocations {

    // MARK: - Properties

    /// The root folder where the source project is located.
    public let baseUrl: URL

    /// The parsed configuration object (loaded from `config.yml`, for example).
    public let config: Config

    // MARK: - Initialization

    /// Initializes a new `SourceConfig` from the project root URL and its configuration.
    ///
    /// - Parameters:
    ///   - sourceUrl: Base URL of the content project root.
    ///   - config: The configuration object parsed from the project.
    public init(
        sourceUrl: URL,
        config: Config
    ) {
        self.baseUrl = sourceUrl
        self.config = config
    }

    // MARK: - Content & Asset URLs

    /// The absolute URL to the contents directory (e.g., Markdown files).
    public var contentsUrl: URL {
        baseUrl.appendingPathComponent(config.contents.path)
    }

    /// The URL to the site settings location
    public var siteSettingsURL: URL {
        baseUrl.appendingPathIfPresent(config.site.settings.path)
    }

    /// The absolute URL to the global site assets directory.
    public var siteAssetsUrl: URL {
        baseUrl.appendingPathComponent(config.site.assets.path)
    }

    // MARK: - Types URLs

    /// The URL to the current theme's type-specific layouts or definitions.
    public var typesUrl: URL {
        baseUrl.appendingPathComponent(config.types.path)
    }

    // MARK: - Blocks URLs

    /// The URL to the current theme's reusable UI blocks directory.
    public var blocksUrl: URL {
        baseUrl.appendingPathComponent(config.blocks.path)
    }

    // MARK: - Pipeline URLs

    /// The URL to the folder containing pipeline configuration files.
    public var pipelinesUrl: URL {
        baseUrl.appendingPathComponent(config.pipelines.path)
    }

    // MARK: - Theme URLs

    /// The URL to the base themes directory.
    public var themesUrl: URL {
        baseUrl.appendingPathComponent(config.themes.location.path)
    }

    /// The URL to the currently active theme's root folder.
    public var currentThemeUrl: URL {
        themesUrl.appendingPathComponent(config.themes.current.path)
    }

    /// The URL to the current theme's asset directory.
    public var currentThemeAssetsUrl: URL {
        currentThemeUrl.appendingPathComponent(config.themes.assets.path)
    }

    /// The URL to the current theme's templates directory.
    public var currentThemeTemplatesUrl: URL {
        currentThemeUrl.appendingPathComponent(config.themes.templates.path)
    }

    // MARK: - Theme Override URLs

    /// The base URL for override-specific theme folders.
    public var currentThemeOverrideUrl: URL {
        themesUrl.appendingPathComponent(config.themes.overrides.path)
    }

    /// The override URL for assets (if present).
    public var currentThemeOverrideAssetsUrl: URL {
        currentThemeOverrideUrl.appendingPathComponent(
            config.themes.assets.path
        )
    }

    /// The override URL for template files (if present).
    public var currentThemeOverrideTemplatesUrl: URL {
        currentThemeOverrideUrl.appendingPathComponent(
            config.themes.templates.path
        )
    }
}
