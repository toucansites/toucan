//
//  Config.swift
//  Toucan
//
//  Created by Tibor Bodecs on 2025. 01. 29..
//

import Foundation

/// Represents the top-level configuration for a content rendering system.
public struct Config: Codable, Equatable {

    // MARK: - Coding Keys

    private enum CodingKeys: CodingKey {
        case pipelines
        case contents
        case themes
        case dateFormats
        case renderer
    }

    // MARK: - Properties

    /// Pipeline configuration used to transform and render content.
    public var pipelines: Pipelines

    /// Configuration for mapping and locating raw content files.
    public var contents: Contents

    /// Theme-related configuration, including layout templates and style resources.
    public var themes: Themes

    /// Global date format settings for rendering and parsing dates.
    public var dateFormats: DateFormats
    
    /// Additional content-specific overrides or configuration extensions.
    public var renderer: RendererConfig

    // MARK: - Defaults

    /// Provides a default `Config` instance using defaults from all subcomponents.
    ///
    /// This is used when configuration fields are missing or omitted.
    public static var defaults: Self {
        .init(
            pipelines: .defaults,
            contents: .defaults,
            themes: .defaults,
            dateFormats: .defaults,
            renderer: .defaults
        )
    }

    // MARK: - Initialization

    /// Initializes a full `Config` instance.
    ///
    /// - Parameters:
    ///   - pipelines: Pipeline configurations.
    ///   - contents: Content mapping configuration.
    ///   - themes: Theme layout and styling definitions.
    ///   - dateFormats: Global or localized date format settings.
    ///   - contentConfigurations: Fine-grained control for specific content types.
    public init(
        pipelines: Pipelines,
        contents: Contents,
        themes: Themes,
        dateFormats: DateFormats,
        renderer: RendererConfig
    ) {
        self.pipelines = pipelines
        self.contents = contents
        self.themes = themes
        self.dateFormats = dateFormats
        self.renderer = renderer
    }

    // MARK: - Decoding

    /// Decodes the `Config` from a structured data source (e.g., YAML or JSON),
    /// applying defaults to any missing fields for robust deserialization.
    ///
    /// - Parameter decoder: The decoder used to load configuration.
    /// - Throws: A decoding error if required structures are malformed.
    public init(from decoder: any Decoder) throws {
        let defaults = Self.defaults
        let container = try? decoder.container(keyedBy: CodingKeys.self)

        guard let container else {
            self = defaults
            return
        }

        self.pipelines =
            try container.decodeIfPresent(Pipelines.self, forKey: .pipelines)
            ?? defaults.pipelines

        self.contents =
            try container.decodeIfPresent(Contents.self, forKey: .contents)
            ?? defaults.contents

        self.themes =
            try container.decodeIfPresent(Themes.self, forKey: .themes)
            ?? defaults.themes

        self.dateFormats =
            try container.decodeIfPresent(
                DateFormats.self,
                forKey: .dateFormats
            )
            ?? defaults.dateFormats

        self.renderer =
            try container.decodeIfPresent(
                RendererConfig.self,
                forKey: .renderer
            ) ?? defaults.renderer

    }
}
