//
//  File.swift
//  toucan
//
//  Created by Tibor Bodecs on 2025. 02. 03..
//

import ToucanModels

extension RenderPipeline {

    public struct Scope {

        // load these contexts
        public let context: Context
        // filter down context fields, empty means no filter
        public let fields: [String]

        public init(
            context: Context = .all,
            fields: [String] = []
        ) {
            self.context = context
            self.fields = fields
        }

        // MARK: - built-in scopes

        public static var reference: Scope {
            .init(
                context: .reference,
                fields: []
            )
        }

        public static var list: Scope {
            .init(
                context: .list,
                fields: []
            )
        }

        public static var detail: Scope {
            .init(
                context: .detail,
                fields: []
            )
        }

        public static var standard: [String: Scope] {
            [
                "reference": reference,
                "list": list,
                "detail": detail,
            ]
        }

        public static var `default`: [String: [String: Scope]] {
            [
                "*": standard
            ]
        }
    }
}
