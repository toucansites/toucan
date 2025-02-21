//
//  File.swift
//  toucan
//
//  Created by Tibor Bodecs on 2025. 02. 21..
//

extension Config {

    public struct Pipelines: Codable {

        enum CodingKeys: CodingKey {
            case path
        }

        public var path: String

        // MARK: - defaults

        public static var defaults: Self {
            .init(
                path: "pipelines"
            )
        }

        // MARK: - init
        
        public init(
            path: String
        ) {
            self.path = path
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
        }
    }
}
