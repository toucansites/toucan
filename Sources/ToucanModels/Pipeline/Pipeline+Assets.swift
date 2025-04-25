//
//  Pipeline+Assets.swift
//  Toucan
//
//  Created by Tibor Bodecs on 2025. 04. 19..
//

extension Pipeline {

    public struct Assets: Decodable {

        public struct Property: Decodable {

            public init(
                action: Action,
                property: String,
                resolvePath: Bool,
                input: Input
            ) {
                self.action = action
                self.property = property
                self.resolvePath = resolvePath
                self.input = input
            }

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

                public init(path: String? = nil, name: String, ext: String) {
                    self.path = path
                    self.name = name
                    self.ext = ext
                }
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
            .init(properties: getDefaultProperties())
        }
        
        public static func getDefaultProperties() -> [Property] {
            [
                .init(
                    action: .add,
                    property: "js",
                    resolvePath: true,
                    input: .init(name: "main", ext: "js")
                ),
                .init(
                    action: .add,
                    property: "css",
                    resolvePath: true,
                    input: .init(name: "style", ext: "css")
                ),
                .init(
                    action: .add,
                    property: "image",
                    resolvePath: true,
                    input: .init(name: "cover", ext: "jpg")
                ),
                .init(
                    action: .add,
                    property: "image",
                    resolvePath: true,
                    input: .init(name: "cover", ext: "png")
                )
                
                // image
                
                /*- action: set
                      property: image
                      resolvePath: true # => add base url, default false
                      file:
                            name: "cover"
                            ext: "jpg"*/

            ]
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
