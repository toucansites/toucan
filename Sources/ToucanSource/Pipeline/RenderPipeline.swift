//
//  rendererconfig.swift
//  TestApp
//
//  Created by Tibor Bodecs on 2025. 01. 16..
//

import ToucanModels

public struct RenderPipeline {

    // content type -> scope key -> scope
    public var scopes: [String: [String: Scope]]
    public var queries: [String: Query]
    public var contentType: ContentTypes
    public var engine: Engine

    public init(
        scopes: [String: [String: Scope]],
        queries: [String: Query],
        contentType: RenderPipeline.ContentTypes,
        engine: RenderPipeline.Engine
    ) {
        self.scopes = scopes
        self.queries = queries
        self.contentType = contentType
        self.engine = engine
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
        for contentType: String,
        key: String
    ) -> Scope {
        let scopes = getScopes(for: contentType)
        // TODO: what should we return if there's no scope definition?
        return scopes[key] ?? .detail
    }
}
