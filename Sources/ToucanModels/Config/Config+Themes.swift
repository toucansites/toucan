//
//  File.swift
//  toucan
//
//  Created by Viasz-Kádi Ferenc on 2025. 03. 01..
//

import Foundation

extension Config {

    public struct Themes: Decodable, Equatable {

        enum CodingKeys: CodingKey {
            case location
            case current
            case assets
            case templates
            case types
            case overrides
        }

        public var location: Location
        public var current: Location
        public var assets: Location
        public var templates: Location
        public var types: Location
        public var overrides: Location

        // MARK: - defaults

        public static var defaults: Self {
            .init(
                location: .init(path: "themes"),
                current: .init(path: "default"),
                assets: .init(path: "assets"),
                templates: .init(path: "templates"),
                types: .init(path: "types"),
                overrides: .init(path: "overrides")
            )
        }

        // MARK: - init

        public init(
            location: Location,
            current: Location,
            assets: Location,
            templates: Location,
            types: Location,
            overrides: Location
        ) {
            self.location = location
            self.current = current
            self.assets = assets
            self.templates = templates
            self.types = types
            self.overrides = overrides
        }

        // MARK: - decoder

        public init(from decoder: any Decoder) throws {
            let defaults = Self.defaults
            let container = try? decoder.container(keyedBy: CodingKeys.self)

            guard let container else {
                self = defaults
                return
            }

            self.location =
                try container.decodeIfPresent(
                    Location.self,
                    forKey: .location
                ) ?? defaults.location

            self.current =
                try container.decodeIfPresent(
                    Location.self,
                    forKey: .current
                ) ?? defaults.current

            self.assets =
                try container.decodeIfPresent(
                    Location.self,
                    forKey: .assets
                ) ?? defaults.assets

            self.templates =
                try container.decodeIfPresent(
                    Location.self,
                    forKey: .templates
                ) ?? defaults.templates

            self.types =
                try container.decodeIfPresent(
                    Location.self,
                    forKey: .types
                ) ?? defaults.types

            self.overrides =
                try container.decodeIfPresent(
                    Location.self,
                    forKey: .overrides
                ) ?? defaults.overrides
        }
    }
}
