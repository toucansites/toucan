//
//  rendererconfig.swift
//  TestApp
//
//  Created by Tibor Bodecs on 2025. 01. 16..
//

import ToucanModels

public struct RenderPipeline {

    public struct Engine {
        var id: String
        var options: AnyValue?

        public init(
            id: String,
            options: AnyValue?
        ) {
            self.id = id
            self.options = options
        }
    }

    public struct ContentTypes: OptionSet {

        public static var single: Self { .init(rawValue: 1 << 0) }
        public static var bundle: Self { .init(rawValue: 1 << 1) }
        public static var all: Self { [single, bundle] }

        // MARK: -

        public let rawValue: UInt

        public init(rawValue: UInt) {
            self.rawValue = rawValue
        }
    }

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

extension RenderPipeline {

    public struct Scope {

        public struct Context: OptionSet {

            public static var properties: Self { .init(rawValue: 1 << 0) }
            public static var contents: Self { .init(rawValue: 1 << 1) }
            public static var relations: Self { .init(rawValue: 1 << 2) }
            public static var queries: Self { .init(rawValue: 1 << 3) }
            public static var all: Self {
                [properties, contents, relations, queries]
            }

            // MARK: -

            public let rawValue: UInt

            public init(rawValue: UInt) {
                self.rawValue = rawValue
            }
        }

        // identifier of the scope, e.g. list, detail, etc.
        public let id: String
        // load these contexts
        public let context: Context
        // filter down context fields, empty means no filter
        public let fields: [String]

        public init(
            id: String,
            context: Context = .all,
            fields: [String] = []
        ) {
            self.id = id
            self.context = context
            self.fields = fields
        }
    }
}

//scopes: [
//    "post": [
//     {
//        id: "list"
//        context: [
//            "contents",
//            "relations",
//            "properties",
//            "queries",
//        ],
//        fields: [
//            "foo"
//        ]
//    }
//    ]
//]
