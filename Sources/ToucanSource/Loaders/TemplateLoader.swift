//
//  TemplateLoader.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 05. 21..
//

import FileManagerKit
import struct Foundation.URL
import ToucanSerialization
import Logging

/// A loader responsible for building a `Template` by collecting assets and templates from various locations.
public struct TemplateLoader {
    // MARK: - Properties

    /// The file system locations relevant to the template loading process.
    let locations: BuiltTargetSourceLocations
    /// The list of file extensions considered as templates.
    let extensions: [String]
    /// The file manager utility used to search and retrieve files.
    let fileManager: FileManagerKit

    let encoder: ToucanEncoder
    let decoder: ToucanDecoder
    let logger: Logger

    // MARK: - Lifecycle

    /// Creates a new instance of `TemplateLoader`.
    /// - Parameters:
    ///   - locations: The locations where template-related files are stored.
    ///   - extensions: The template file extensions to look for.
    ///   - fileManager: The file manager utility to use for locating files.
    public init(
        locations: BuiltTargetSourceLocations,
        extensions: [String] = ["mustache", "html"],
        fileManager: FileManagerKit,
        encoder: ToucanEncoder,
        decoder: ToucanDecoder,
        logger: Logger
    ) {
        self.locations = locations
        self.extensions = extensions
        self.fileManager = fileManager
        self.encoder = encoder
        self.decoder = decoder
        self.logger = logger
    }

    // MARK: - Functions

    func loadTemplate(
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

    func loadTemplateMetadata(
        at url: URL
    ) throws(TemplateLoaderError) -> Template.Metadata {
        do {
            return try ObjectLoader(
                url: url,
                locations: fileManager.find(
                    name: "template",
                    extensions: ["yaml", "yml"],
                    at: url
                ),
                encoder: encoder,
                decoder: decoder,
                logger: logger
            )
            .load(Template.Metadata.self)
        }
        catch {
            throw .init(type: "\(Template.Metadata.self)", error: error)
        }
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

        let metadata = try loadTemplateMetadata(
            at: locations.currentTemplateURL
        )

        let template = try Template(
            metadata: metadata,
            components: .init(
                assets: assets,
                views: templates.map {
                    try loadTemplate(
                        at: locations.currentTemplateViewsURL,
                        path: $0
                    )
                }
            ),
            overrides: .init(
                assets: assetOverrides,
                views: templateOverrides.map {
                    try loadTemplate(
                        at: locations.currentTemplateViewsOverridesURL,
                        path: $0
                    )
                }
            ),
            content: .init(
                assets: contentAssetOverrides,
                views: contentTemplateOverrides.map {
                    try loadTemplate(
                        at: locations.contentsURL,
                        path: $0,
                        isContentOverride: true
                    )
                }
            )
        )
        return template
    }
}
