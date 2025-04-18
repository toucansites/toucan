//
//  ContentDefinition.swift
//  Toucan
//
//  Created by Tibor Bodecs on 2025. 01. 15..
//

/// Describes a content type definition including schema, relations, and associated queries.
///
/// `ContentDefinition` is used to declare how a particular content type (e.g., blog, project, product)
/// should be parsed, validated, and queried in the pipeline.
public struct ContentDefinition: Decodable, Equatable {

    // MARK: - Coding Keys

    private enum CodingKeys: CodingKey {
        case id
        case `default`
        case paths
        case properties
        case relations
        case queries
    }

    // MARK: - Properties

    /// A unique identifier for this content type (e.g., `"blog"`, `"author"`).
    public var id: String

    /// Indicates whether this is the default content type fallback.
    ///
    /// If `true`, this type will be used only when the content does not explicitly declare its type,
    /// and no matching `paths` from other types apply.
    ///
    /// ⚠️ Only one content type in the system may be marked as `default`; otherwise, an error will occur.
    public var `default`: Bool

    /// A list of file path patterns (globs or prefixes) used to associate source files with this content type.
    ///
    /// Example: `["posts/**", "blog/*.md"]`
    public var paths: [String]

    /// A map of property names to their type definitions.
    ///
    /// These represent structured, typed fields such as `title`, `published`, `authorId`, etc.
    public var properties: [String: Property]

    /// A map of relation names to their relationship configuration.
    ///
    /// These define links to other content (e.g., `author`, `relatedPosts`).
    public var relations: [String: Relation]

    /// Named queries that can be used within scopes or as reusable filters for rendering this type.
    public var queries: [String: Query]

    // MARK: - Initialization

    /// Creates a new `ContentDefinition` instance.
    ///
    /// - Parameters:
    ///   - id: Unique identifier for the content type.
    ///   - default: Whether this is the fallback default type.
    ///   - paths: Glob-like patterns that identify matching content files.
    ///   - properties: Field definitions and types.
    ///   - relations: Definitions of inter-content relationships.
    ///   - queries: Reusable queries for list or scoped views.
    public init(
        id: String,
        default: Bool = false,
        paths: [String],
        properties: [String: Property],
        relations: [String: Relation],
        queries: [String: Query]
    ) {
        self.id = id
        self.default = `default`
        self.paths = paths
        self.properties = properties
        self.relations = relations
        self.queries = queries
    }

    // MARK: - Decoding

    /// Decodes a `ContentDefinition` from a structured format (e.g., YAML or JSON),
    /// applying defaults for missing optional fields.
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let id = try container.decode(String.self, forKey: .id)
        let `default` =
            (try? container.decode(Bool.self, forKey: .default)) ?? false
        let paths =
            try container.decodeIfPresent([String].self, forKey: .paths) ?? []
        let properties =
            try container.decodeIfPresent(
                [String: Property].self,
                forKey: .properties
            ) ?? [:]
        let relations =
            try container.decodeIfPresent(
                [String: Relation].self,
                forKey: .relations
            ) ?? [:]
        let queries =
            try container.decodeIfPresent(
                [String: Query].self,
                forKey: .queries
            ) ?? [:]

        self.init(
            id: id,
            default: `default`,
            paths: paths,
            properties: properties,
            relations: relations,
            queries: queries
        )
    }
}
