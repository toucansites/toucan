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
import FileManagerKitBuilder

@testable import ToucanSource

@Suite
struct BuildTargetSourceLocationsTestSuite {

    @Test()
    func defaults() async throws {
        let prefix = "src"
        let def = "default"

        let templatesPath = "\(prefix)/templates"
        let templatePath = "\(templatesPath)/\(def)"
        let overridesPath = "\(templatesPath)/overrides/\(def)"

        let expectedBase = "\(prefix)"
        let expectedAssets = "\(prefix)/assets"
        let expectedSettings = "\(prefix)"
        let expectedContents = "\(prefix)/contents"
        let expectedTypes = "\(prefix)/types"
        let expectedBlocks = "\(prefix)/blocks"
        let expectedPipelines = "\(prefix)/pipelines"
        let expectedTemplates = templatesPath
        let expectedCurrentTemplate = templatePath
        let expectedTemplateAssets = "\(templatePath)/assets"
        let expectedTemplateTemplates = "\(templatePath)/views"
        let expectedOverrides = overridesPath
        let expectedOverrideAssets = "\(overridesPath)/assets"
        let expectedOverrideTemplates = "\(overridesPath)/views"

        let url = URL(filePath: prefix)
        let locations = BuiltTargetSourceLocations(
            sourceUrl: url,
            config: .defaults
        )

        let basePath = locations.baseUrl.path()
        let assetsPath = locations.siteAssetsURL.path()
        let settingsPath = locations.siteSettingsURL.path()
        let contentsPath = locations.contentsUrl.path()
        let typesPath = locations.typesUrl.path()
        let blocksPath = locations.blocksUrl.path()
        let pipelinesPath = locations.pipelinesUrl.path()
        let templatesPathValue = locations.templatesURL.path()
        let currentTemplatePath = locations.currentTemplateURL.path()
        let templateAssetsPath = locations.currentTemplateAssetsURL.path()
        let templateTemplatesPath = locations.currentTemplateViewsURL.path()
        let overridesPathValue = locations.currentTemplateOverridesURL.path()
        let overrideAssetsPath = locations.currentTemplateAssetOverridesURL
            .path()
        let overrideTemplatesPath = locations.currentTemplateViewsOverridesUrl
            .path()

        #expect(basePath == expectedBase)
        #expect(assetsPath == expectedAssets)
        #expect(settingsPath == expectedSettings)
        #expect(contentsPath == expectedContents)
        #expect(typesPath == expectedTypes)
        #expect(blocksPath == expectedBlocks)
        #expect(pipelinesPath == expectedPipelines)
        #expect(templatesPathValue == expectedTemplates)
        #expect(currentTemplatePath == expectedCurrentTemplate)
        #expect(templateAssetsPath == expectedTemplateAssets)
        #expect(templateTemplatesPath == expectedTemplateTemplates)
        #expect(overridesPathValue == expectedOverrides)
        #expect(overrideAssetsPath == expectedOverrideAssets)
        #expect(overrideTemplatesPath == expectedOverrideTemplates)
    }
}
