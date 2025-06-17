//
//  Pipeline+Engine.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 02. 03..
//

public extension Pipeline {
    /// Represents the rendering engine configuration used in a content pipeline.
    struct Engine: Codable {
        // MARK: - Coding Keys

        private enum CodingKeys: CodingKey {
            case id
            case options
        }

        /// A unique identifier for the engine (e.g., `"html"`, `"api"`, `"rss"`).
        public var id: String

        /// A map of engine-specific configuration options.
        ///
        /// These options are engine-dependent and may define things like layout names,
        /// file extensions, or custom behaviors.
        public var options: [String: AnyCodable]

        // MARK: - Initialization

        /// Initializes a new engine configuration.
        ///
        /// - Parameters:
        ///   - id: The unique identifier of the engine type.
        ///   - options: A dictionary of custom configuration options.
        public init(
            id: String,
            options: [String: AnyCodable]
        ) {
            self.id = id
            self.options = options
        }

        // MARK: - Decoding

        /// Decodes an `Engine` instance from a configuration source.
        ///
        /// If `options` is not defined, it defaults to an empty dictionary.
        ///
        /// - Throws: A decoding error if required fields are missing or malformed.
        public init(
            from decoder: any Decoder
        ) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            let id = try container.decode(String.self, forKey: .id)

            let options =
                try container.decodeIfPresent(
                    [String: AnyCodable].self,
                    forKey: .options
                ) ?? [:]

            self.init(id: id, options: options)
        }
    }
}
