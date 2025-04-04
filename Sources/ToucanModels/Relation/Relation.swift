//
//  Relation.swift
//  Toucan
//
//  Created by Tibor Bodecs on 2025. 01. 21..
//

public struct Relation: Decodable, Equatable {

    enum CodingKeys: CodingKey {
        case references
        case `type`
        case order
    }

    public var references: String
    public var `type`: RelationType
    public var order: Order?

    // MARK: - init

    public init(
        references: String,
        `type`: RelationType,
        order: Order? = nil
    ) {
        self.references = references
        self.`type` = `type`
        self.order = order
    }

    // MARK: - decoder

    public init(
        from decoder: any Decoder
    ) throws {
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
