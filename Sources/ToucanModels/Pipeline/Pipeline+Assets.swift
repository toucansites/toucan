//
//  Pipeline+Assets.swift
//  Toucan
//
//  Created by Tibor Bodecs on 2025. 04. 19..
//

extension Pipeline {

    public struct Assets: Decodable {

        public struct Property: Decodable {

            public enum Action: String, Decodable {
                case add
                case set
                case load
                case parse
            }

            public struct Input: Decodable {
                public var path: String?
                public var name: String
                public var ext: String
            }

            public var action: Action
            public var property: String
            public var resolvePath: Bool
            public var input: Input
        }

        private enum CodingKeys: CodingKey {
            case properties
        }

        public var properties: [Property]

        public static var defaults: Self {
            .init(properties: [])
        }

        public init(
            properties: [Property]
        ) {
            self.properties = properties
        }

        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            let properties =
                try container.decodeIfPresent(
                    [Property].self,
                    forKey: .properties
                ) ?? []

            self.init(properties: properties)
        }
    }
}
