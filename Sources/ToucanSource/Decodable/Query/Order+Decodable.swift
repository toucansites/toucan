//
//  File.swift
//  toucan
//
//  Created by Tibor Bodecs on 2025. 01. 31..
//

import ToucanModels

extension Order: Decodable {

    enum CodingKeys: CodingKey {
        case key
        case direction
    }

    public init(from decoder: any Decoder) throws {
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
