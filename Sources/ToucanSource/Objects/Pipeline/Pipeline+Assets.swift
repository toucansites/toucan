//
//  Pipeline+Assets.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 04. 19..
//

public extension Pipeline {
    /// Represents a collection of asset declarations used during content rendering.
    ///
    /// Assets include static files like JavaScript, CSS, and images that are attached
    /// to the output content, either by setting paths, loading files, or parsing content.
    struct Assets: Codable {

        private enum CodingKeys: CodingKey, CaseIterable {
            case behaviors
            case properties
        }

        /// Describes the file location for the asset.
        public struct Location: Codable {

            /// An optional path to the asset file.
            public var path: String?
            /// The base name of the file (without extension).
            public var name: String
            /// The file extension (e.g., `"css"`, `"js"`).
            public var ext: String

            //

            /// Initializes a new `Input` describing an asset file.
            ///
            /// - Parameters:
            ///   - path: Optional path to the file.
            ///   - name: The file name without extension.
            ///   - ext: The file extension.
            public init(
                path: String? = nil,
                name: String,
                ext: String
            ) {
                self.path = path
                self.name = name
                self.ext = ext
            }
        }

        /// Describes a transformation between two asset locations, typically used for converting input files to a desired output format.
        ///
        /// The `Behavior` struct is useful in defining how assets should be handled during processing, for example,
        /// converting a SCSS file to a CSS file or minifying JavaScript.
        ///
        /// - Properties:
        ///   - id: A unique identifier for the behavior.
        ///   - input: The source location of the asset.
        ///   - output: The destination location for the processed asset.
        public struct Behavior: Codable {

            private enum CodingKeys: CodingKey, CaseIterable {
                case id
                case input
                case output
            }

            /// The unique identifier for the behavior.
            public var id: String
            /// The input location for the behavior.
            public var input: Location
            /// The output location for the behavior.
            public var output: Location

            /// Initializes a behavior
            ///
            /// - Properties:
            ///   - id: A unique identifier for the behavior.
            ///   - input: The source location of the asset.
            ///   - output: The destination location for the processed asset.
            public init(
                id: String,
                input: Location,
                output: Location
            ) {
                self.id = id
                self.input = input
                self.output = output
            }

            /// Decodes a `Behavior` instance from a configuration source (e.g., JSON/YAML).
            ///
            /// Missing fields default
            public init(
                from decoder: any Decoder
            ) throws {
                try decoder.validateUnknownKeys(keyType: CodingKeys.self)

                let container = try decoder.container(keyedBy: CodingKeys.self)

                let id = try container.decode(String.self, forKey: .id)

                let input =
                    try container.decodeIfPresent(
                        Location.self,
                        forKey: .input
                    )
                    ?? .init(
                        name: "*",
                        ext: "*"
                    )

                let output =
                    try container.decodeIfPresent(
                        Location.self,
                        forKey: .output
                    )
                    ?? .init(
                        name: "*",
                        ext: "*"
                    )

                self.init(
                    id: id,
                    input: input,
                    output: output
                )
            }
        }

        /// Represents a single asset manipulation instruction within the `Assets` configuration.
        public struct Property: Codable {

            /// Defines how the asset should be applied or processed.
            public enum Action: String, Codable {
                /// Add the asset to an existing list or collection.
                case add
                /// Overwrite or explicitly set the asset value.
                case set
                /// Load the asset from a specified path or resource.
                case load
                /// Parse the asset, typically used for dynamic formats (e.g., JSON, YAML).
                case parse
            }

            /// The action to perform for this asset.
            public var action: Action
            /// The logical asset key or category (e.g., `"js"`, `"image"`).
            public var property: String
            /// Indicates whether the path to the file should be automatically resolved.
            public var resolvePath: Bool
            /// Describes the input file for the asset.
            public var input: Location

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
                input: Location
            ) {
                self.action = action
                self.property = property
                self.resolvePath = resolvePath
                self.input = input
            }
        }

        /// Returns a default asset configuration commonly used for HTML pipelines.
        public static var defaults: Self {
            .init(
                behaviors: [],
                properties: []
            )
        }

        /// A list of asset behaviors
        public var behaviors: [Behavior]

        /// A list of asset manipulation rules.
        public var properties: [Property]

        /// Initializes an `Assets` instance with a given set of properties.
        ///
        /// - Parameters:
        ///   - behaviors: The array of asset behaviors.
        ///   - properties: The array of asset properties to include.
        public init(
            behaviors: [Behavior] = [],
            properties: [Property] = []
        ) {
            self.behaviors = behaviors
            self.properties = properties
        }

        /// Decodes the `Assets` instance from a decoder, applying empty defaults if necessary.
        ///
        /// - Parameter decoder: The decoder to use for deserialization.
        /// - Throws: An error if decoding fails.
        public init(
            from decoder: any Decoder
        ) throws {
            try decoder.validateUnknownKeys(keyType: CodingKeys.self)

            let container = try decoder.container(keyedBy: CodingKeys.self)

            let defaults = Self.defaults

            let behaviors =
                try container.decodeIfPresent(
                    [Behavior].self,
                    forKey: .behaviors
                ) ?? defaults.behaviors

            let properties =
                try container.decodeIfPresent(
                    [Property].self,
                    forKey: .properties
                ) ?? defaults.properties

            self.init(
                behaviors: behaviors,
                properties: properties
            )
        }
    }
}
