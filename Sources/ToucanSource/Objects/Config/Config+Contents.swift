//
//  Config+Contents.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 02. 21..
//

public extension Config {
    /// Defines file system paths for locating raw content and its associated assets.
    struct Contents: Codable, Equatable {

        private enum CodingKeys: CodingKey {
            case path
            case assets
        }

        /// Provides a default content configuration using `contents` for source files
        /// and `assets` for media or supporting files.
        public static var defaults: Self {
            .init(
                path: "contents",
                assets: .init(path: "assets")
            )
        }

        /// The root directory path where raw content files (e.g., Markdown, YAML) are located.
        ///
        /// Example: `"contents"` or `"src/content"`
        public var path: String

        /// The location configuration for assets (e.g., images, attachments) linked to the content.
        public var assets: Location

        /// Initializes a custom `Contents` configuration.
        ///
        /// - Parameters:
        ///   - path: The content folder path.
        ///   - assets: The associated assets folder configuration.
        public init(
            path: String,
            assets: Location
        ) {
            self.path = path
            self.assets = assets
        }

        /// Decodes a `Contents` configuration from a serialized format.
        ///
        /// If values are missing, falls back to sensible defaults.
        public init(
            from decoder: any Decoder
        ) throws {
            let defaults = Self.defaults

            guard
                let container = try? decoder.container(keyedBy: CodingKeys.self)
            else {
                self = defaults
                return
            }

            self.path =
                try container.decodeIfPresent(
                    String.self,
                    forKey: .path
                ) ?? defaults.path

            self.assets =
                try container.decodeIfPresent(
                    Location.self,
                    forKey: .assets
                ) ?? defaults.assets
        }
    }
}
