//
//  Pipeline+Assets.swift
//  Toucan
//
//  Created by Tibor Bodecs on 2025. 04. 19..
//

extension Pipeline {

    /// Represents a collection of asset declarations used during content rendering.
    ///
    /// Assets include static files like JavaScript, CSS, and images that are attached
    /// to the output content, either by setting paths, loading files, or parsing content.
    public struct Assets: Decodable {

        /// Represents a single asset manipulation instruction within the `Assets` configuration.
        public struct Property: Decodable {

            /// Initializes a new `Property` describing an asset manipulation.
            ///
            /// - Parameters:
            ///   - action: The type of action to perform (e.g., `.set`, `.add`).
            ///   - property: The logical key or name for the asset (e.g., `"css"`).
            ///   - resolvePath: Whether to resolve the input file path dynamically.
            ///   - input: The input file descriptor.
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

            /// Defines how the asset should be applied or processed.
            public enum Action: String, Decodable {
                /// Add the asset to an existing list or collection.
                case add
                /// Overwrite or explicitly set the asset value.
                case set
                /// Load the asset from a specified path or resource.
                case load
                /// Parse the asset, typically used for dynamic formats (e.g., JSON).
                case parse
            }

            /// Describes the file input for the asset.
            public struct Input: Decodable {
                /// An optional path to the asset file.
                public var path: String?
                /// The base name of the file (without extension).
                public var name: String
                /// The file extension (e.g., `"css"`, `"js"`).
                public var ext: String

                /// Initializes a new `Input` describing an asset file.
                ///
                /// - Parameters:
                ///   - path: Optional path to the file.
                ///   - name: The file name without extension.
                ///   - ext: The file extension.
                public init(path: String? = nil, name: String, ext: String) {
                    self.path = path
                    self.name = name
                    self.ext = ext
                }
            }

            /// The action to perform for this asset.
            public var action: Action
            /// The logical asset key or category (e.g., `"js"`, `"image"`).
            public var property: String
            /// Indicates whether the path to the file should be automatically resolved.
            public var resolvePath: Bool
            /// Describes the input file for the asset.
            public var input: Input
        }

        private enum CodingKeys: CodingKey {
            case properties
        }

        /// A list of asset manipulation rules.
        public var properties: [Property]

        /// Returns a default asset configuration commonly used for HTML pipelines.
        public static var defaults: Self {
            .init(properties: getDefaultProperties())
        }

        /// Provides default `Property` values for a standard rendering pipeline.
        public static func getDefaultProperties() -> [Property] {
            [
                .init(
                    action: .set,
                    property: "js",
                    resolvePath: true,
                    input: .init(name: "main", ext: "js")
                ),
                .init(
                    action: .set,
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
                ),
                .init(
                    action: .add,
                    property: "image",
                    resolvePath: true,
                    input: .init(name: "cover", ext: "webp")
                ),
            ]
        }

        /// Initializes an `Assets` instance with a given set of properties.
        ///
        /// - Parameter properties: The array of asset properties to include.
        public init(
            properties: [Property]
        ) {
            self.properties = properties
        }

        /// Decodes the `Assets` instance from a decoder, applying empty defaults if necessary.
        ///
        /// - Parameter decoder: The decoder to use for deserialization.
        /// - Throws: An error if decoding fails.
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
