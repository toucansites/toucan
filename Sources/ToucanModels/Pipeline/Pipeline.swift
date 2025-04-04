//
//  Pipeline.swift
//  Toucan
//
//  Created by Tibor Bodecs on 2025. 01. 16..
//

public struct Pipeline: Decodable {

    enum CodingKeys: CodingKey {
        case id
        case scopes
        case queries
        case dataTypes
        case contentTypes
        case iterators
        case transformers
        case engine
        case output
    }

    public var id: String
    // content type -> scope key -> scope
    public var scopes: [String: [String: Scope]]
    public var queries: [String: Query]
    public var dataTypes: DataTypes
    public var contentTypes: ContentTypes
    public var iterators: [String: Query]
    public var transformers: [String: TransformerPipeline]
    public var engine: Engine
    public var output: Output

    // MARK: - init

    public init(
        id: String,
        scopes: [String: [String: Scope]],
        queries: [String: Query],
        dataTypes: DataTypes,
        contentTypes: ContentTypes,
        iterators: [String: Query],
        transformers: [String: TransformerPipeline],
        engine: Pipeline.Engine,
        output: Output
    ) {
        self.id = id
        self.scopes = scopes
        self.queries = queries
        self.dataTypes = dataTypes
        self.contentTypes = contentTypes
        self.iterators = iterators
        self.transformers = transformers
        self.engine = engine
        self.output = output
    }

    // MARK: - decoder

    public init(
        from decoder: any Decoder
    ) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let id = try container.decode(
            String.self,
            forKey: .id
        )

        let defaultScopes = Scope.default

        let userScopes =
            try container.decodeIfPresent(
                [String: [String: Scope]].self,
                forKey: .scopes
            ) ?? [:]

        let scopes = defaultScopes.recursivelyMerged(with: userScopes)

        let queries =
            try container.decodeIfPresent(
                [String: Query].self,
                forKey: .queries
            ) ?? [:]

        let dataTypes =
            try container.decodeIfPresent(
                DataTypes.self,
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

        let transformers =
            try container.decodeIfPresent(
                [String: TransformerPipeline].self,
                forKey: .transformers
            ) ?? [:]

        let engine = try container.decode(
            Engine.self,
            forKey: .engine
        )

        let output = try container.decode(
            Output.self,
            forKey: .output
        )

        self.init(
            id: id,
            scopes: scopes,
            queries: queries,
            dataTypes: dataTypes,
            contentTypes: contentTypes,
            iterators: iterators,
            transformers: transformers,
            engine: engine,
            output: output
        )
    }

    // MARK: -

    public func getScopes(
        for contentType: String
    ) -> [String: Scope] {
        if let scopes = scopes[contentType] {
            return scopes
        }
        return scopes["*"] ?? [:]
    }

    // - proper scope keys for reference, list, detail
    // - what should we return if there's no scope definition?
    public func getScope(
        keyedBy key: String,
        for contentType: String
    ) -> Scope {
        let scopes = getScopes(for: contentType)
        return scopes[key] ?? .detail
    }
}
