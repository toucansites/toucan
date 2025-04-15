//
//  SourceConfig.swift
//  Toucan
//
//  Created by Viasz-Kádi Ferenc on 2025. 03. 01..
//

import Foundation

public struct SourceConfig {

    let sourceUrl: URL
    public let config: Config

    public init(sourceUrl: URL, config: Config) {
        self.sourceUrl = sourceUrl
        self.config = config
    }

    public var contentsUrl: URL {
        sourceUrl.appendingPathComponent(config.contents.path)
    }

    /// Global site assets.
    public var assetsUrl: URL {
        contentsUrl.appendingPathComponent(config.contents.assets.path)
    }

    public var themesUrl: URL {
        sourceUrl.appendingPathComponent(config.themes.location.path)
    }

    public var pipelinesUrl: URL {
        sourceUrl.appendingPathComponent(config.pipelines.path)
    }

    // MARK: - theme

    public var currentThemeUrl: URL {
        themesUrl.appendingPathComponent(config.themes.current.path)
    }

    public var currentThemeAssetsUrl: URL {
        currentThemeUrl.appendingPathComponent(config.themes.assets.path)
    }

    public var currentThemeTemplatesUrl: URL {
        currentThemeUrl.appendingPathComponent(config.themes.templates.path)
    }

    public var currentThemeTypesUrl: URL {
        currentThemeUrl.appendingPathComponent(config.themes.types.path)
    }

    public var currentThemeBlocksUrl: URL {
        currentThemeUrl.appendingPathComponent(config.themes.blocks.path)
    }

    // MARK: - theme overrides

    public var currentThemeOverrideUrl: URL {
        themesUrl.appendingPathComponent(config.themes.overrides.path)
    }

    public var currentThemeOverrideAssetsUrl: URL {
        currentThemeOverrideUrl.appendingPathComponent(
            config.themes.assets.path
        )
    }

    public var currentThemeOverrideTemplatesUrl: URL {
        currentThemeOverrideUrl.appendingPathComponent(
            config.themes.templates.path
        )
    }

    public var currentThemeOverrideTypesUrl: URL {
        currentThemeOverrideUrl.appendingPathComponent(
            config.themes.types.path
        )
    }

    public var currentThemeOverrideBlocksUrl: URL {
        currentThemeUrl.appendingPathComponent(
            config.themes.blocks.path
        )
    }

}
