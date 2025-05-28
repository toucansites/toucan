//
//  Pipeline.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 01. 16..
//

/// Represents a full content transformation pipeline,
/// including scopes, queries, content types, engines, and outputs.
///
/// A pipeline defines how data flows from content source to final rendered output.
public struct Pipeline: Decodable {

    // MARK: - Coding Keys

    private enum CodingKeys: CodingKey {
        case id
        case definesType
        case scopes
        case queries
        case dataTypes
        case contentTypes
        case iterators
        case assets
        case transformers
        case engine
        case output
    }

    // MARK: - Properties

    /// Unique identifier for the pipeline.
    public var id: String

    /// A Boolean value indicating whether the pipeline defines a virual type.
    public var definesType: Bool

    /// A nested map of content type → scope key → scope definition.
    ///
    /// This allows for per-content-type rendering rules (e.g., `detail`, `list`, `reference`).
    public var scopes: [String: [String: Scope]]

    /// Named query definitions that can be reused in scopes or iterators.
    public var queries: [String: Query]

    /// Definitions for global or scoped data types (e.g., formats, types).
    public var dataTypes: Config.DataTypes

    /// Definitions for all known content types in the system.
    public var contentTypes: ContentTypes

    /// Static and external assets (e.g., JavaScript, CSS, images) used in rendering.
    public var assets: Assets

    /// Special iterator queries used for generating repeated content structures (e.g., pages in a list).
    public var iterators: [String: Query]

    /// Optional transformation pipelines, applied before rendering.
    public var transformers: [String: Transformers]

    /// The rendering engine to use (e.g., HTML, JSON, RSS).
    public var engine: Engine

    /// Output configuration for file generation and routing.
    public var output: Output

    // MARK: - Initialization

    /// Initializes a fully-defined `Pipeline` object.
    public init(
        id: String,
        definesType: Bool,
        scopes: [String: [String: Scope]],
        queries: [String: Query],
        dataTypes: Config.DataTypes,
        contentTypes: ContentTypes,
        iterators: [String: Query],
        assets: Assets,
        transformers: [String: Transformers],
        engine: Pipeline.Engine,
        output: Output
    ) {
        self.id = id
        self.definesType = definesType
        self.scopes = scopes
        self.queries = queries
        self.dataTypes = dataTypes
        self.contentTypes = contentTypes
        self.iterators = iterators
        self.assets = assets
        self.transformers = transformers
        self.engine = engine
        self.output = output
    }

    // MARK: - Decoding

    /// Decodes a pipeline from configuration, merging with defaults where applicable.
    ///
    /// Uses `Scope.default` as the baseline for scope resolution.
    public init(
        from decoder: any Decoder
    ) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let id = try container.decode(String.self, forKey: .id)
        let definesType =
            try container.decodeIfPresent(Bool.self, forKey: .definesType)
            ?? false

        //        let defaultScopes = Scope.default
        let userScopes =
            try container.decodeIfPresent(
                [String: [String: Scope]].self,
                forKey: .scopes
            ) ?? [:]
        //        let scopes = defaultScopes.recursivelyMerged(with: userScopes)

        let queries =
            try container.decodeIfPresent(
                [String: Query].self,
                forKey: .queries
            ) ?? [:]

        let dataTypes =
            try container.decodeIfPresent(
                Config.DataTypes.self,
                forKey: .dataTypes
            ) ?? .defaults

        let contentTypes =
            try container.decodeIfPresent(
                ContentTypes.self,
                forKey: .contentTypes
            ) ?? .defaults

        let iterators =
            try container.decodeIfPresent(
                [String: Query].self,
                forKey: .iterators
            ) ?? [:]

        let assets =
            try container.decodeIfPresent(
                Assets.self,
                forKey: .assets
            ) ?? .defaults

        let transformers =
            try container.decodeIfPresent(
                [String: Transformers].self,
                forKey: .transformers
            ) ?? [:]

        let engine = try container.decode(Engine.self, forKey: .engine)
        let output = try container.decode(Output.self, forKey: .output)

        self.init(
            id: id,
            definesType: definesType,
            scopes: userScopes,  // TODO: fix this
            queries: queries,
            dataTypes: dataTypes,
            contentTypes: contentTypes,
            iterators: iterators,
            assets: assets,
            transformers: transformers,
            engine: engine,
            output: output
        )
    }

    // MARK: - Scope Helpers

    /// Returns all scopes for a given content type.
    ///
    /// If no direct match is found, falls back to the wildcard `*` scopes.
    ///
    /// - Parameter contentType: The content type key (e.g., `"post"`).
    /// - Returns: A map of scope keys (e.g., `"list"`, `"detail"`) to `Scope` values.
    public func getScopes(
        for contentType: String
    ) -> [String: Scope] {
        if let scopes = scopes[contentType] {
            return scopes
        }
        return scopes["*"] ?? [:]
    }

    /// Returns a single scope for a given content type and scope key (e.g., `"list"`, `"detail"`).
    ///
    /// Defaults to `.detail` if no specific match is found.
    ///
    /// - Parameters:
    ///   - key: The scope key (e.g., `"detail"`, `"reference"`).
    ///   - contentType: The content type key.
    /// - Returns: A `Scope` object.
    public func getScope(
        keyedBy key: String,
        for contentType: String
    ) -> Scope {
        let scopes = getScopes(for: contentType)
        return scopes[key] ?? .detail
    }
}
