//
//  ThemeLoader.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 05. 21..
//

import FileManagerKit
import struct Foundation.URL

/// A loader responsible for building a `Theme` by collecting assets and templates from various locations.
public struct ThemeLoader {

    /// The file system locations relevant to the theme loading process.
    let locations: BuiltTargetSourceLocations
    /// The list of file extensions considered as templates.
    let extensions: [String]
    /// The file manager utility used to search and retrieve files.
    let fileManager: FileManagerKit

    /// Creates a new instance of `ThemeLoader`.
    /// - Parameters:
    ///   - locations: The locations where theme-related files are stored.
    ///   - extensions: The template file extensions to look for.
    ///   - fileManager: The file manager utility to use for locating files.
    public init(
        locations: BuiltTargetSourceLocations,
        extensions: [String] = ["mustache", "html"],
        fileManager: FileManagerKit
    ) {
        self.locations = locations
        self.extensions = extensions
        self.fileManager = fileManager
    }

    ///
    /// Loads and builds a `Theme` by collecting assets and templates from predefined locations.
    ///
    /// - Returns: A fully constructed `Theme` instance.
    /// - Throws: An error if file discovery fails.
    public func load() throws -> Theme {
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
                templates: try templates.map {
                    try loadTemplate(
                        at: locations.currentThemeTemplatesUrl,
                        path: $0
                    )
                }
            ),
            overrides: .init(
                assets: assetOverrides,
                templates: try templateOverrides.map {
                    try loadTemplate(
                        at: locations.currentThemeTemplateOverridesUrl,
                        path: $0
                    )
                }
            ),
            content: .init(
                assets: contentAssetOverrides,
                templates: try contentTemplateOverrides.map {
                    try loadTemplate(
                        at: locations.contentsUrl,
                        path: $0,
                        isContentOverride: true
                    )
                }
            )
        )
        return theme
    }

    func loadTemplate(
        at url: URL,
        path: String,
        isContentOverride: Bool = false
    ) throws -> Template {

        let basePath =
            path
            .split(separator: ".")
            .dropLast()
            .joined(separator: ".")

        let id =
            if isContentOverride {
                basePath
                    .split(separator: "/")
                    .last.map(String.init) ?? ""
            }
            else {
                basePath
                    .replacingOccurrences(of: "/", with: ".")
            }

        let contents = try String(
            contentsOf: url.appendingPathIfPresent(path),
            encoding: .utf8
        )
        return .init(
            id: id,
            path: path,
            contents: contents
        )
    }

    /// Returns a dictionary of template IDs and their contents.
    ///
    /// - Parameter theme: The `Theme` instance to extract templates from.
    /// - Returns: A dictionary where the keys are template IDs and the values are their contents.
    public func getTemplatesIDsWithContents(
        _ theme: Theme
    ) -> [String: String] {
        var results: [String: String] = [:]

        for template in theme.components.templates {
            results[template.id] = template.contents
        }
        for template in theme.overrides.templates {
            results[template.id] = template.contents
        }
        for template in theme.content.templates {
            results[template.id] = template.contents
        }

        return .init(
            uniqueKeysWithValues: results.sorted { $0.key < $1.key }
        )
    }
}
