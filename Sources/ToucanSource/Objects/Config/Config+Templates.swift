//
//  Config+Templates.swift
//  Toucan
//
//  Created by Viasz-Kádi Ferenc on 2025. 03. 01..
//

import Foundation

public extension Config {
    /// Defines the structure and paths for working with templates in the system.
    struct Templates: Codable, Equatable {
        // MARK: - Nested Types

        // MARK: - Coding Keys

        private enum CodingKeys: CodingKey {
            case location
            case current
            case assets
            case views
            case overrides
        }

        // MARK: - Static Computed Properties

        // MARK: - Defaults

        /// Returns the default template configuration with all folders under the `"templates"` base.
        public static var defaults: Self {
            .init(
                location: .init(path: "templates"),
                current: .init(path: "default"),
                assets: .init(path: "assets"),
                views: .init(path: "views"),
                overrides: .init(path: "overrides")
            )
        }

        // MARK: - Properties

        /// The base folder where all templates are stored (e.g., `"templates"`).
        public var location: Location

        /// The subfolder or identifier of the currently selected template (e.g., `"default"`, `"dark"`).
        public var current: Location

        /// The path inside the template where static assets (e.g., CSS, JS, images) are stored.
        public var assets: Location

        /// The path to the folder containing template views (e.g., HTML or markup layouts).
        public var views: Location

        /// A folder for override files that replace core behavior or template (optional).
        public var overrides: Location

        // MARK: - Lifecycle

        // MARK: - Initialization

        /// Initializes a configuration.
        ///
        /// - Parameters:
        ///   - location: The base path containing all template folders.
        ///   - current: The name or path of the active template.
        ///   - assets: Folder path for template assets.
        ///   - views: Folder path for views.
        ///   - overrides: Folder path for template overrides.
        public init(
            location: Location,
            current: Location,
            assets: Location,
            views: Location,
            overrides: Location
        ) {
            self.location = location
            self.current = current
            self.assets = assets
            self.views = views
            self.overrides = overrides
        }

        // MARK: - Decoding

        /// Decodes a configuration from serialized input, falling back to default values when missing.
        public init(
            from decoder: any Decoder
        ) throws {
            let defaults = Self.defaults
            let container = try? decoder.container(keyedBy: CodingKeys.self)

            guard let container else {
                self = defaults
                return
            }

            self.location =
                try container.decodeIfPresent(Location.self, forKey: .location)
                ?? defaults.location

            self.current =
                try container.decodeIfPresent(Location.self, forKey: .current)
                ?? defaults.current

            self.assets =
                try container.decodeIfPresent(Location.self, forKey: .assets)
                ?? defaults.assets

            self.views =
                try container.decodeIfPresent(Location.self, forKey: .views)
                ?? defaults.views

            self.overrides =
                try container.decodeIfPresent(Location.self, forKey: .overrides)
                ?? defaults.overrides
        }
    }
}
