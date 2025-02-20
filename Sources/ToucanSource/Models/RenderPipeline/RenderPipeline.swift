//
//  rendererconfig.swift
//  TestApp
//
//  Created by Tibor Bodecs on 2025. 01. 16..
//

import ToucanModels

//transformers:
//    pipelines:
//        post:
//          run:
//            - name: swiftinit
//          isMarkdownResult: false

public struct ContentTransformer: Codable {
    public var name: String
    public var arguments: [String: String]

    public init(
        name: String,
        arguments: [String: String] = [:]
    ) {
        self.name = name
        self.arguments = arguments
    }
}

public struct TransformerPipeline: Codable {
    public var run: [ContentTransformer]
    public var isMarkdownResult: Bool

    public init(
        run: [ContentTransformer] = [],
        isMarkdownResult: Bool = true
    ) {
        self.run = run
        self.isMarkdownResult = isMarkdownResult
    }
}

public struct RenderPipeline {

    // content type -> scope key -> scope
    public var scopes: [String: [String: Scope]]
    public var queries: [String: Query]
    public var dataTypes: DataTypes
    public var contentTypes: ContentTypes
    public var iterators: [String: Query]
    public var transformers: [String: TransformerPipeline]
    public var engine: Engine
    public var output: Output

    public init(
        scopes: [String: [String: Scope]],
        queries: [String: Query],
        dataTypes: DataTypes,
        contentTypes: ContentTypes,
        iterators: [String: Query],
        transformers: [String: TransformerPipeline],
        engine: RenderPipeline.Engine,
        output: Output
    ) {
        self.scopes = scopes
        self.queries = queries
        self.dataTypes = dataTypes
        self.contentTypes = contentTypes
        self.iterators = iterators
        self.transformers = transformers
        self.engine = engine
        self.output = output
    }

    public func getScopes(
        for contentType: String
    ) -> [String: Scope] {
        if let scopes = scopes[contentType] {
            return scopes
        }
        return scopes["*"] ?? [:]
    }

    public func getScope(
        keyedBy key: String,
        for contentType: String
    ) -> Scope {
        let scopes = getScopes(for: contentType)
        // TODO: what should we return if there's no scope definition?
        return scopes[key] ?? .detail
    }
}
