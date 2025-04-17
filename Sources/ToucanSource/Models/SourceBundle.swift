//
//  SourceBundle.swift
//  Toucan
//
//  Created by Tibor Bodecs on 2025. 01. 31..
//

import Foundation
import ToucanContent
import ToucanModels

/// A complete in-memory representation of a content source bundle,
/// including its configuration, content, pipelines, templates, and more.
///
/// Typically, this structure is built after parsing a content directory
/// and used as input to render or transform content.
public struct SourceBundle {

    // MARK: - Properties

    /// The root location of the source on the filesystem.
    /// This usually points to the folder where the source content resides.
    public var location: URL

    /// Global configuration for the project, often loaded from `config.yml`.
    public var config: Config

    /// Source-specific configuration, typically parsed from `source.yml` or equivalent.
    public var sourceConfig: SourceConfig

    /// Site-wide settings, often defined in `site.yml`.
    public var settings: Settings

    /// List of content pipelines.
    public var pipelines: [Pipeline]

    /// All parsed content entries within the source.
    public var contents: [Content]

    /// A collection of custom Markdown block directives to be supported in rendering.
    public var blockDirectives: [MarkdownBlockDirective]

    /// A mapping of template names to their raw string contents.
    /// These are used for rendering pages or layout components.
    public var templates: [String: String]

    /// The base URL for resolving relative paths or links in rendered content.
    public var baseUrl: String

    // MARK: - Initialization

    /// Initializes a fully populated `SourceBundle` from its constituent components.
    ///
    /// - Parameters:
    ///   - location: Filesystem URL of the source root.
    ///   - config: The main configuration for the site/project.
    ///   - sourceConfig: Configuration specific to this source group.
    ///   - settings: Site-level metadata like title, language, etc.
    ///   - pipelines: Any content transformation pipelines to apply.
    ///   - contents: Parsed content entries.
    ///   - blockDirectives: Custom block directive definitions.
    ///   - templates: Named templates used for rendering.
    ///   - baseUrl: The base URL to be used for link resolution.
    public init(
        location: URL,
        config: Config,
        sourceConfig: SourceConfig,
        settings: Settings,
        pipelines: [Pipeline],
        contents: [Content],
        blockDirectives: [MarkdownBlockDirective],
        templates: [String: String],
        baseUrl: String
    ) {
        self.location = location
        self.config = config
        self.sourceConfig = sourceConfig
        self.settings = settings
        self.pipelines = pipelines
        self.contents = contents
        self.blockDirectives = blockDirectives
        self.templates = templates
        self.baseUrl = baseUrl
    }
}
