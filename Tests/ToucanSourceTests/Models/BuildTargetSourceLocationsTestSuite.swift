//
//  BuildTargetSourceLocationsTestSuite.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 05. 21..
//

import Testing
import Foundation
import ToucanCore
import ToucanSerialization
import FileManagerKit
import FileManagerKitTesting

@testable import ToucanSource

@Suite
struct BuildTargetSourceLocationsTestSuite {

    @Test()
    func defaults() async throws {
        let prefix = "src"
        let def = "default"

        let themesPath = "\(prefix)/themes"
        let themePath = "\(themesPath)/\(def)"
        let overridesPath = "\(themesPath)/overrides/\(def)"

        let expectedBase = "\(prefix)"
        let expectedAssets = "\(prefix)/assets"
        let expectedSettings = "\(prefix)"
        let expectedContents = "\(prefix)/contents"
        let expectedTypes = "\(prefix)/types"
        let expectedBlocks = "\(prefix)/blocks"
        let expectedPipelines = "\(prefix)/pipelines"
        let expectedThemes = themesPath
        let expectedCurrentTheme = themePath
        let expectedThemeAssets = "\(themePath)/assets"
        let expectedThemeTemplates = "\(themePath)/templates"
        let expectedOverrides = overridesPath
        let expectedOverrideAssets = "\(overridesPath)/assets"
        let expectedOverrideTemplates = "\(overridesPath)/templates"

        let url = URL(filePath: prefix)
        let locations = BuiltTargetSourceLocations(
            sourceUrl: url,
            config: .defaults
        )

        let basePath = locations.baseUrl.path()
        let assetsPath = locations.siteAssetsUrl.path()
        let settingsPath = locations.siteSettingsURL.path()
        let contentsPath = locations.contentsUrl.path()
        let typesPath = locations.typesUrl.path()
        let blocksPath = locations.blocksUrl.path()
        let pipelinesPath = locations.pipelinesUrl.path()
        let themesPathValue = locations.themesUrl.path()
        let currentThemePath = locations.currentThemeUrl.path()
        let themeAssetsPath = locations.currentThemeAssetsUrl.path()
        let themeTemplatesPath = locations.currentThemeTemplatesUrl.path()
        let overridesPathValue = locations.currentThemeOverridesUrl.path()
        let overrideAssetsPath = locations.currentThemeAssetOverridesUrl.path()
        let overrideTemplatesPath = locations.currentThemeTemplateOverridesUrl
            .path()

        #expect(basePath == expectedBase)
        #expect(assetsPath == expectedAssets)
        #expect(settingsPath == expectedSettings)
        #expect(contentsPath == expectedContents)
        #expect(typesPath == expectedTypes)
        #expect(blocksPath == expectedBlocks)
        #expect(pipelinesPath == expectedPipelines)
        #expect(themesPathValue == expectedThemes)
        #expect(currentThemePath == expectedCurrentTheme)
        #expect(themeAssetsPath == expectedThemeAssets)
        #expect(themeTemplatesPath == expectedThemeTemplates)
        #expect(overridesPathValue == expectedOverrides)
        #expect(overrideAssetsPath == expectedOverrideAssets)
        #expect(overrideTemplatesPath == expectedOverrideTemplates)
    }
}
