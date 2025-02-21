//
//  File.swift
//  toucan
//
//  Created by Tibor Bodecs on 2025. 02. 03..
//

extension Pipeline {

    public struct ContentTypes: Decodable {

        enum CodingKeys: CodingKey {
            case include
            case exclude
            case lastUpdate
        }

        public var include: [String]
        public var exclude: [String]
        public var lastUpdate: [String]

        // MARK: - defaults

        public static var defaults: Self {
            .init(
                include: [],
                exclude: [],
                lastUpdate: []
            )
        }

        // MARK: - init

        public init(
            include: [String],
            exclude: [String],
            lastUpdate: [String]
        ) {
            self.include = include
            self.exclude = exclude
            self.lastUpdate = lastUpdate
        }

        // MARK: - decoder

        public init(
            from decoder: any Decoder
        ) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            let include =
                try container.decodeIfPresent(
                    [String].self,
                    forKey: .include
                ) ?? []

            let exclude =
                try container.decodeIfPresent(
                    [String].self,
                    forKey: .exclude
                ) ?? []

            let lastUpdate =
                try container.decodeIfPresent(
                    [String].self,
                    forKey: .lastUpdate
                ) ?? []

            self.init(
                include: include,
                exclude: exclude,
                lastUpdate: lastUpdate
            )
        }

        // MARK: -

        public func isAllowed(contentType: String) -> Bool {
            if exclude.contains(contentType) {
                return false
            }
            if include.isEmpty {
                return true
            }
            return include.contains(contentType)
        }
    }
}
