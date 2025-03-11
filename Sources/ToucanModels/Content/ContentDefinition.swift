//
//  contenttype.swift
//  TestApp
//
//  Created by Tibor Bodecs on 2025. 01. 15..
//

public struct ContentDefinition: Decodable, Equatable {

    enum CodingKeys: CodingKey {
        case id
        case `default`
        case paths
        case properties
        case relations
        case queries
    }

    /// content type identifier
    public var id: String

    /// If `true`, the `ContentDefinition` will be used as the fallback type only when the user has not explicitly specified one
    /// **and** the system cannot determine it from the provided `paths`.
    /// An error is thrown if multiple types are marked as the default.
    public var `default`: Bool

    /// paths to lookup for contents
    public var paths: [String]

    public var properties: [String: Property]
    public var relations: [String: Relation]
    public var queries: [String: Query]

    // MARK: - init

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

    // MARK: - decoder

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
