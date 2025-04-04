//
//  Order.swift
//  Toucan
//
//  Created by Tibor Bodecs on 2025. 01. 15..
//

public struct Order: Decodable, Equatable {

    enum CodingKeys: CodingKey {
        case key
        case direction
    }

    public var key: String
    public var direction: Direction

    // MARK: - init

    public init(
        key: String,
        direction: Direction = .asc
    ) {
        self.key = key
        self.direction = direction
    }

    // MARK: - decoder

    public init(
        from decoder: any Decoder
    ) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let key = try container.decode(String.self, forKey: .key)
        let direction =
            try container.decodeIfPresent(Direction.self, forKey: .direction)
            ?? .defaults

        self.init(
            key: key,
            direction: direction
        )
    }
}
