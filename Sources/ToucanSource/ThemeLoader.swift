//
//  ThemeLoader.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 05. 21..
//

import FileManagerKit

struct ThemeLoader {

    let locations: BuiltTargetSourceLocations
    let extensions: [String]
    let fileManager: FileManagerKit

    init(
        locations: BuiltTargetSourceLocations,
        extensions: [String] = ["mustache", "html"],
        fileManager: FileManagerKit
    ) {
        self.locations = locations
        self.extensions = extensions
        self.fileManager = fileManager
    }

    func load() throws -> Theme {
        let assets = fileManager.find(
            recursively: true,
            at: locations.currentThemeAssetsUrl
        )
        let templates = fileManager.find(
            extensions: extensions,
            recursively: true,
            at: locations.currentThemeTemplatesUrl
        )

        let assetOverrides = fileManager.find(
            recursively: true,
            at: locations.currentThemeAssetOverridesUrl
        )

        let templateOverrides = fileManager.find(
            extensions: extensions,
            recursively: true,
            at: locations.currentThemeTemplateOverridesUrl
        )

        let contentAssetOverrides = fileManager.find(
            recursively: true,
            at: locations.siteAssetsUrl
        )

        let contentTemplateOverrides = fileManager.find(
            extensions: extensions,
            recursively: true,
            at: locations.contentsUrl
        )

        let theme = Theme(
            baseUrl: locations.themesUrl,
            components: .init(
                assets: assets,
                templates: templates.map { .init(path: $0) }
            ),
            overrides: .init(
                assets: assetOverrides,
                templates: templateOverrides.map { .init(path: $0) }
            ),
            content: .init(
                assets: contentAssetOverrides,
                templates: contentTemplateOverrides.map { .init(path: $0) }
            )
        )
        return theme
    }
}
