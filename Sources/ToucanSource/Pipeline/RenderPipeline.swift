//
//  rendererconfig.swift
//  TestApp
//
//  Created by Tibor Bodecs on 2025. 01. 16..
//

import ToucanModels

public struct RenderPipeline {

    public var scopes: [String: [Scope]]
    public var queries: [String: Query]
    public var contentType: ContentTypes
    public var engine: Engine

    public init(
        scopes: [String: [Scope]],
        queries: [String: Query],
        contentType: RenderPipeline.ContentTypes,
        engine: RenderPipeline.Engine
    ) {
        self.scopes = scopes
        self.queries = queries
        self.contentType = contentType
        self.engine = engine
    }
}
