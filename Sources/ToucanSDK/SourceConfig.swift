//
//  File.swift
//  toucan
//
//  Created by Viasz-Kádi Ferenc on 2025. 03. 01..
//

import Foundation
import ToucanModels

struct SourceConfig {

    let sourceUrl: URL
    let config: Config

    var contentsUrl: URL {
        sourceUrl.appendingPathComponent(config.contents.path)
    }

    /// Global site assets.
    var assetsUrl: URL {
        contentsUrl.appendingPathComponent(config.contents.assets.path)
    }

    var themesUrl: URL {
        sourceUrl.appendingPathComponent(config.themes.location.path)
    }

    var pipelinesUrl: URL {
        sourceUrl.appendingPathComponent(config.pipelines.path)
    }

    // MARK: - theme

    var currentThemeUrl: URL {
        themesUrl.appendingPathComponent(config.themes.current.path)
    }

    var currentThemeAssetsUrl: URL {
        currentThemeUrl.appendingPathComponent(config.themes.assets.path)
    }

    var currentThemeTemplatesUrl: URL {
        currentThemeUrl.appendingPathComponent(config.themes.templates.path)
    }

    var currentThemeTypesUrl: URL {
        currentThemeUrl.appendingPathComponent(config.themes.types.path)
    }

    var currentThemeBlocksUrl: URL {
        currentThemeUrl.appendingPathComponent(config.themes.blocks.path)
    }

    // MARK: - theme overrides

    var currentThemeOverrideUrl: URL {
        themesUrl.appendingPathComponent(config.themes.overrides.path)
    }

    var currentThemeOverrideAssetsUrl: URL {
        currentThemeOverrideUrl.appendingPathComponent(
            config.themes.assets.path
        )
    }

    var currentThemeOverrideTemplatesUrl: URL {
        currentThemeOverrideUrl.appendingPathComponent(
            config.themes.templates.path
        )
    }

    var currentThemeOverrideTypesUrl: URL {
        currentThemeOverrideUrl.appendingPathComponent(
            config.themes.types.path
        )
    }

    var currentThemeOverrideBlocksUrl: URL {
        currentThemeUrl.appendingPathComponent(
            config.themes.blocks.path
        )
    }

}
