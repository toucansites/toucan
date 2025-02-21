//
//  File.swift
//  toucan
//
//  Created by Tibor Bodecs on 2025. 02. 21..
//

extension Config {

    public struct Contents: Decodable {

        enum CodingKeys: CodingKey {
            case path
            case assets
        }

        public var path: String
        public var assets: Location

        // MARK: - defaults

        public static var defaults: Self {
            .init(
                path: "contents",
                assets: .init(
                    path: "assets"
                )
            )
        }

        // MARK: - init

        public init(
            path: String,
            assets: Location
        ) {
            self.path = path
            self.assets = assets
        }

        // MARK: - decoder

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
