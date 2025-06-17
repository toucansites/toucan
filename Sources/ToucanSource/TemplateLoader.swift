//
//  TemplateLoader.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 05. 21..
//

import FileManagerKit
import struct Foundation.URL

/// A loader responsible for building a `Template` by collecting assets and templates from various locations.
public struct TemplateLoader {
    /// The file system locations relevant to the template loading process.
    let locations: BuiltTargetSourceLocations
    /// The list of file extensions considered as templates.
    let extensions: [String]
    /// The file manager utility used to search and retrieve files.
    let fileManager: FileManagerKit

    /// Creates a new instance of `TemplateLoader`.
    /// - Parameters:
    ///   - locations: The locations where template-related files are stored.
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

    func loadView(
        at url: URL,
        path: String,
        isContentOverride: Bool = false
    ) throws -> View {
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

    ///
    /// Loads and builds a `Template` by collecting assets and templates from predefined locations.
    ///
    /// - Returns: A fully constructed `Template` instance.
    /// - Throws: An error if file discovery fails.
    public func load() throws -> Template {
        let assets = fileManager.find(
            recursively: true,
            at: locations.currentTemplateAssetsURL
        )
        let templates = fileManager.find(
            extensions: extensions,
            recursively: true,
            at: locations.currentTemplateViewsURL
        )

        let assetOverrides = fileManager.find(
            recursively: true,
            at: locations.currentTemplateAssetOverridesURL
        )

        let templateOverrides = fileManager.find(
            extensions: extensions,
            recursively: true,
            at: locations.currentTemplateViewsOverridesURL
        )

        let contentAssetOverrides = fileManager.find(
            recursively: true,
            at: locations.siteAssetsURL
        )

        let contentTemplateOverrides = fileManager.find(
            extensions: extensions,
            recursively: true,
            at: locations.contentsURL
        )

        let template = try Template(
            baseURL: locations.templatesURL,
            components: .init(
                assets: assets,
                views: templates.map {
                    try loadView(
                        at: locations.currentTemplateViewsURL,
                        path: $0
                    )
                }
            ),
            overrides: .init(
                assets: assetOverrides,
                views: templateOverrides.map {
                    try loadView(
                        at: locations.currentTemplateViewsOverridesURL,
                        path: $0
                    )
                }
            ),
            content: .init(
                assets: contentAssetOverrides,
                views: contentTemplateOverrides.map {
                    try loadView(
                        at: locations.contentsURL,
                        path: $0,
                        isContentOverride: true
                    )
                }
            )
        )
        return template
    }

    /// Returns a dictionary of template IDs and their contents.
    ///
    /// - Parameter template: The `Template` instance to extract templates from.
    /// - Returns: A dictionary where the keys are template IDs and the values are their contents.
    public func getTemplatesIDsWithContents(
        _ template: Template
    ) -> [String: String] {
        var results: [String: String] = [:]

        let views =
            template.components.views + template.overrides.views
                + template.content.views

        for view in views {
            results[view.id] = view.contents
        }

        return .init(
            uniqueKeysWithValues: results.sorted { $0.key < $1.key }
        )
    }
}
