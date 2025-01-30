//
//  contenttype.swift
//  TestApp
//
//  Created by Tibor Bodecs on 2025. 01. 15..
//

public struct ContentDefinition {

    /// content type identifier
    public var type: String
    /// paths to lookup for contents
    public var paths: [String]

    public var properties: [Property]
    public var relations: [Relation]
    public var queries: [String: Query]

    public init(
        type: String,
        paths: [String],
        properties: [Property],
        relations: [Relation],
        queries: [String: Query]
    ) {
        self.type = type
        self.paths = paths
        self.properties = properties
        self.relations = relations
        self.queries = queries
    }
}
