//
//  Config.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 01. 29..
//

import Foundation

/// Represents the top-level configuration for a content rendering system.
public struct Config: Codable, Equatable {

    // MARK: - Coding Keys

    private enum CodingKeys: CodingKey {
        case site
        case pipelines
        case contents
        case types
        case blocks
        case templates
        case dataTypes
        case renderer
    }

    // MARK: - Properties

    /// Global site configuration.
    public var site: Site

    /// Pipeline configuration used to transform and render content.
    public var pipelines: Pipelines

    /// Configuration for mapping and locating raw content files.
    public var contents: Contents

    /// The folder where type-specific templates or definitions reside.
    public var types: Types

    /// A folder for reusable UI block components (e.g., hero, footer, card).
    public var blocks: Blocks

    /// Template-related configuration, including layout templates and style resources.
    public var templates: Templates

    /// Global date format settings for rendering and parsing dates.
    public var dataTypes: DataTypes

    /// Additional content-specific overrides or configuration extensions.
    public var renderer: RendererConfig

    // MARK: - Defaults

    /// Provides a default `Config` instance using defaults from all subcomponents.
    ///
    /// This is used when configuration fields are missing or omitted.
    public static var defaults: Self {
        .init(
            site: .defaults,
            pipelines: .defaults,
            contents: .defaults,
            types: .defaults,
            blocks: .defaults,
            templates: .defaults,
            dataTypes: .defaults,
            renderer: .defaults
        )
    }

    // MARK: - Initialization

    /// Initializes a full `Config` instance.
    ///
    /// - Parameters:
    ///   - site: Site configuration.
    ///   - pipelines: Pipeline configurations.
    ///   - contents: Content mapping configuration.
    ///   - types: Folder path for type definitions.
    ///   - blocks: Folder path for reusable block templates.
    ///   - templates: Template layout and styling definitions.
    ///   - dataTypes: Data type related configurations.
    ///   - renderer: Fine-grained control for specific content types.
    public init(
        site: Site,
        pipelines: Pipelines,
        contents: Contents,
        types: Types,
        blocks: Blocks,
        templates: Templates,
        dataTypes: DataTypes,
        renderer: RendererConfig
    ) {
        self.site = site
        self.pipelines = pipelines
        self.contents = contents
        self.types = types
        self.blocks = blocks
        self.templates = templates
        self.dataTypes = dataTypes
        self.renderer = renderer
    }

    // MARK: - Decoding

    /// Decodes the `Config` from a structured data source (e.g., YAML or JSON),
    /// applying defaults to any missing fields for robust deserialization.
    ///
    /// - Parameter decoder: The decoder used to load configuration.
    /// - Throws: A decoding error if required structures are malformed.
    public init(
        from decoder: any Decoder
    ) throws {
        let defaults = Self.defaults
        let container = try? decoder.container(keyedBy: CodingKeys.self)

        guard let container else {
            self = defaults
            return
        }

        self.site =
            try container.decodeIfPresent(
                Site.self,
                forKey: .site
            ) ?? defaults.site

        self.pipelines =
            try container.decodeIfPresent(
                Pipelines.self,
                forKey: .pipelines
            ) ?? defaults.pipelines

        self.contents =
            try container.decodeIfPresent(
                Contents.self,
                forKey: .contents
            ) ?? defaults.contents

        self.types =
            try container.decodeIfPresent(
                Types.self,
                forKey: .types
            ) ?? defaults.types

        self.blocks =
            try container.decodeIfPresent(
                Blocks.self,
                forKey: .blocks
            ) ?? defaults.blocks

        self.templates =
            try container.decodeIfPresent(
                Templates.self,
                forKey: .templates
            ) ?? defaults.templates

        self.dataTypes =
            try container.decodeIfPresent(
                DataTypes.self,
                forKey: .dataTypes
            ) ?? defaults.dataTypes

        self.renderer =
            try container.decodeIfPresent(
                RendererConfig.self,
                forKey: .renderer
            ) ?? defaults.renderer

    }
}
