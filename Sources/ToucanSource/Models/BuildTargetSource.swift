//
//  BuildTargetSource.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 01. 31..
//

import struct Foundation.URL

/// A complete in-memory representation of a content source bundle,
/// including its configuration, content, pipelines, templates, and more.
///
/// Typically, this structure is built after parsing a content directory
/// and used as input to render or transform content.
public struct BuildTargetSource {

    // MARK: - Properties

    /// The root location of the source on the filesystem.
    /// This usually points to the folder where the source content resides.
    public var location: URL

    /// The target to use to build the site.
    public var target: Target

    /// Global configuration for the project, often loaded from `config.yml`.
    public var config: Config

    /// Site-wide settings, often defined in `site.yml`.
    public var settings: Settings

    /// List of content pipelines.
    public var pipelines: [Pipeline]

    /// Definitions for content types, typically used to classify and validate content entries.
    public var contentDefinitions: [ContentDefinition]

    /// A list of raw content items parsed from the source directory.
    public var rawContents: [RawContent]

    /// A list of custom block directives used in Markdown rendering.
    public var blockDirectives: [Block]

    // MARK: - Initialization

    /// Initializes a fully populated `BuildTargetSource` from its constituent components.
    ///
    /// - Parameters:
    ///   - location: Filesystem URL of the source root.
    ///   - target: The target to use to build the site.
    ///   - config: The main configuration for the site/project.
    ///   - settings: Site-level metadata like title, language, etc.
    ///   - pipelines: Any content transformation pipelines to apply.
    ///   - contentDefinitions: Definitions for content types in this source.
    ///   - rawContents: Parsed content entries from the source.
    ///   - blockDirectives: Definitions of custom Markdown block directives.
    public init(
        location: URL,
        target: Target = .standard,
        config: Config = .defaults,
        settings: Settings = .defaults,
        pipelines: [Pipeline] = [],
        contentDefinitions: [ContentDefinition] = [],
        rawContents: [RawContent] = [],
        blockDirectives: [Block] = [],
    ) {
        self.location = location
        self.target = target
        self.config = config
        self.settings = settings
        self.pipelines = pipelines
        self.contentDefinitions = contentDefinitions
        self.rawContents = rawContents
        self.blockDirectives = blockDirectives
    }
}
