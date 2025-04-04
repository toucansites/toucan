//
//  Pipeline+Scope.swift
//  Toucan
//
//  Created by Tibor Bodecs on 2025. 02. 03..
//

extension Pipeline {

    public struct Scope: Decodable {

        enum CodingKeys: CodingKey {
            case id
            case context
            case fields
        }

        public var context: Context
        public var fields: [String]

        // MARK: - init

        public init(
            context: Context = .detail,
            fields: [String] = []
        ) {
            self.context = context
            self.fields = fields
        }

        // MARK: - decoder

        public init(
            from decoder: any Decoder
        ) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            let context =
                try container.decodeIfPresent(
                    Context.self,
                    forKey: .context
                ) ?? .detail
            let fields =
                try container.decodeIfPresent(
                    [String].self,
                    forKey: .fields
                ) ?? []

            self.init(
                context: context,
                fields: fields
            )
        }

        // MARK: - scope helpers for compund contexts

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

        // MARK: - defaults

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
