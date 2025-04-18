//
//  Config+Themes.swift
//  Toucan
//
//  Created by Viasz-Kádi Ferenc on 2025. 03. 01..
//

import Foundation

extension Config {

    /// Defines the structure and paths for working with themes in the system.
    public struct Themes: Codable, Equatable {

        // MARK: - Coding Keys

        private enum CodingKeys: CodingKey {
            case location
            case current
            case assets
            case templates
            case overrides
        }

        // MARK: - Properties

        /// The base folder where all themes are stored (e.g., `"themes"`).
        public var location: Location

        /// The subfolder or identifier of the currently selected theme (e.g., `"default"`, `"dark"`).
        public var current: Location

        /// The path inside the theme where static assets (e.g., CSS, JS, images) are stored.
        public var assets: Location

        /// The path to the folder containing template files (e.g., HTML or markup layouts).
        public var templates: Location

        /// A folder for override files that replace core behavior or templates (optional).
        public var overrides: Location

        // MARK: - Defaults

        /// Returns the default theme configuration with all folders under the `"themes"` base.
        ///
        /// Example:
        /// ```
        /// themes/
        /// └── default/
        ///     ├── assets/
        ///     ├── templates/
        ///     └── overrides/
        /// ```
        public static var defaults: Self {
            .init(
                location: .init(path: "themes"),
                current: .init(path: "default"),
                assets: .init(path: "assets"),
                templates: .init(path: "templates"),
                overrides: .init(path: "overrides")
            )
        }

        // MARK: - Initialization

        /// Initializes a `Themes` configuration.
        ///
        /// - Parameters:
        ///   - location: The base path containing all theme folders.
        ///   - current: The name or path of the active theme.
        ///   - assets: Folder path for theme assets.
        ///   - templates: Folder path for templates.
        ///   - overrides: Folder path for template or config overrides.
        public init(
            location: Location,
            current: Location,
            assets: Location,
            templates: Location,
            overrides: Location
        ) {
            self.location = location
            self.current = current
            self.assets = assets
            self.templates = templates
            self.overrides = overrides
        }

        // MARK: - Decoding

        /// Decodes a `Themes` configuration from serialized input, falling back to default values when missing.
        public init(from decoder: any Decoder) throws {
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

            self.templates =
                try container.decodeIfPresent(Location.self, forKey: .templates)
                ?? defaults.templates
            
            self.overrides =
                try container.decodeIfPresent(Location.self, forKey: .overrides)
                ?? defaults.overrides
        }
    }
}
