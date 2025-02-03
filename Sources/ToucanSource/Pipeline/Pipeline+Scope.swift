//
//  File.swift
//  toucan
//
//  Created by Tibor Bodecs on 2025. 02. 03..
//

import ToucanModels

extension RenderPipeline {

    public struct Scope {

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

        // MARK: - built-in scopes

        public static var reference: Scope {
            .init(
                id: "reference",
                context: [.properties],
                fields: []
            )
        }

        public static var list: Scope {
            .init(
                id: "list",
                context: [.properties, .relations],
                fields: []
            )
        }

        public static var detail: Scope {
            .init(
                id: "detail",
                context: .all,
                fields: []
            )
        }

        public static var any: String { "*" }
        public static var standard: [Scope] {
            [
                reference,
                list,
                detail,
            ]
        }
    }
}
