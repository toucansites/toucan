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
        var options: [String: AnyValue]
    }

    public struct ContentTypes: OptionSet {

        public static var single: ContentTypes { .init(rawValue: 1 << 0) }
        public static var bundle: ContentTypes { .init(rawValue: 1 << 1) }
        public static var all: ContentTypes { [single, bundle] }

        // MARK: -

        public let rawValue: UInt

        public init(rawValue: UInt) {
            self.rawValue = rawValue
        }
    }

    public var queries: [String: Query]
    public var contentType: ContentTypes
    public var engine: Engine
}
