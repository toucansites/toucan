//
//  File.swift
//  toucan
//
//  Created by Tibor Bodecs on 2025. 01. 31..
//

import ToucanModels

extension Relation: Decodable {

    enum CodingKeys: CodingKey {
        case references
        case `type`
        case order
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let references = try container.decode(String.self, forKey: .references)
        let type = try container.decode(RelationType.self, forKey: .type)
        let order = try container.decodeIfPresent(Order.self, forKey: .order)

        self.init(
            references: references,
            type: type,
            order: order
        )
    }
}
