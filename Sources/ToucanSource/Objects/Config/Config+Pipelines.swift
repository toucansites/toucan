//
//  Config+Pipelines.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 02. 21..
//

public extension Config {
    /// Represents the location of pipeline configuration files.
    struct Pipelines: Codable, Equatable {

        private enum CodingKeys: CodingKey, CaseIterable {
            case path
        }

        /// Provides a default `Pipelines` configuration pointing to `"pipelines"`.
        public static var defaults: Self {
            .init(path: "pipelines")
        }

        /// The relative or absolute path to the folder containing pipeline configuration files.
        ///
        /// Example: `"pipelines"` (default), or `"config/pipelines"`
        public var path: String

        /// Initializes a new pipelines configuration.
        ///
        /// - Parameter path: The directory where pipeline configuration files are stored.
        public init(path: String) {
            self.path = path
        }

        /// Decodes the `Pipelines` configuration from a structured source.
        ///
        /// Falls back to `.defaults` if no container is available or the field is missing.
        public init(
            from decoder: any Decoder
        ) throws {
            try decoder.validateUnknownKeys(keyType: CodingKeys.self)

            let defaults = Self.defaults
            let container = try? decoder.container(keyedBy: CodingKeys.self)

            guard let container else {
                self = defaults
                return
            }

            self.path =
                try container.decodeIfPresent(String.self, forKey: .path)
                ?? defaults.path
        }
    }
}
