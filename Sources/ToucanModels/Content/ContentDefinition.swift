//
//  contenttype.swift
//  TestApp
//
//  Created by Tibor Bodecs on 2025. 01. 15..
//

public struct ContentDefinition: Decodable {

    enum CodingKeys: CodingKey {
        case `type`
        case paths
        case properties
        case relations
        case queries
    }

    /// content type identifier
    public var type: String
    /// paths to lookup for contents
    public var paths: [String]

    public var properties: [String: Property]
    public var relations: [String: Relation]
    public var queries: [String: Query]

    // MARK: - init

    public init(
        type: String,
        paths: [String],
        properties: [String: Property],
        relations: [String: Relation],
        queries: [String: Query]
    ) {
        self.type = type
        self.paths = paths
        self.properties = properties
        self.relations = relations
        self.queries = queries
    }

    // MARK: - decoder

    public init(
        from decoder: any Decoder
    ) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let type = try container.decode(String.self, forKey: .type)
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
            type: type,
            paths: paths,
            properties: properties,
            relations: relations,
            queries: queries
        )
    }
}
