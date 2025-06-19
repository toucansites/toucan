//
//  Config+Site.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 02. 21..
//

public extension Config {
    /// Defines file system paths for locating site related resources.
    struct Site: Codable, Equatable {

        private enum CodingKeys: CodingKey {
            case assets
            case settings
        }

        /// Provides a default content configuration
        public static var defaults: Self {
            .init(
                assets: .init(path: "assets"),
                settings: .init(path: "")
            )
        }

        /// The location of the global site assets.
        public var assets: Location

        /// The location of the site settings.
        public var settings: Location

        /// Initializes a custom `Site` configuration.
        ///
        /// - Parameters:
        ///   - assets: The assets folder location.
        ///   - settings: The settings (site.yml) file location.
        public init(
            assets: Location,
            settings: Location
        ) {
            self.assets = assets
            self.settings = settings
        }

        /// Decodes a `Site` configuration from a serialized format.
        ///
        /// If values are missing, falls back to default values.
        public init(
            from decoder: any Decoder
        ) throws {
            let defaults = Self.defaults

            guard
                let container = try? decoder.container(
                    keyedBy: CodingKeys.self
                )
            else {
                self = defaults
                return
            }

            self.assets =
                try container.decodeIfPresent(
                    Location.self,
                    forKey: .assets
                ) ?? defaults.assets

            self.settings =
                try container.decodeIfPresent(
                    Location.self,
                    forKey: .settings
                ) ?? defaults.settings
        }
    }
}
