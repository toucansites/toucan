//
//  Config+Types.swift
//  Toucan
//
//  Created by Viasz-Kádi Ferenc on 2025. 04. 18..
//

public extension Config {
    /// Represents the location of type configuration files.
    struct Types: Sendable, Codable, Equatable {

        private enum CodingKeys: CodingKey {
            case path
        }

        /// Provides a default `Types` configuration pointing to `"types"`.
        public static var defaults: Self {
            .init(path: "types")
        }

        /// The relative or absolute path to the folder containing type configuration files.
        ///
        /// Example: `"types"` (default), or `"config/types"`
        public var path: String

        /// Initializes a new types configuration.
        ///
        /// - Parameter path: The directory where type configuration files are stored.
        public init(
            path: String
        ) {
            self.path = path
        }

        /// Decodes the `Types` configuration from a structured source.
        ///
        /// Falls back to `.defaults` if no container is available or the field is missing.
        public init(
            from decoder: any Decoder
        ) throws {
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
