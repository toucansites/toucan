//
//  Config+Blocks.swift
//  Toucan
//
//  Created by Viasz-Kádi Ferenc on 2025. 04. 18..
//

public extension Config {
    /// Represents the location of block configuration files.
    struct Blocks: Codable, Equatable {
        // MARK: - Nested Types

        // MARK: - Coding Keys

        private enum CodingKeys: CodingKey {
            case path
        }

        // MARK: - Static Computed Properties

        // MARK: - Defaults

        /// Provides a default `Blocks` configuration pointing to `"blocks"`.
        public static var defaults: Self {
            .init(path: "blocks")
        }

        // MARK: - Properties

        /// The relative or absolute path to the folder containing block configuration files.
        ///
        /// Example: `"blocks"` (default), or `"config/blocks"`
        public var path: String

        // MARK: - Lifecycle

        // MARK: - Initialization

        /// Initializes a new blocks configuration.
        ///
        /// - Parameter path: The directory where blocks configuration files are stored.
        public init(path: String) {
            self.path = path
        }

        // MARK: - Decoding

        /// Decodes the `Pipelines` configuration from a structured source.
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
