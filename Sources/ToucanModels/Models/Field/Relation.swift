//
//  File.swift
//  ToucanV2
//
//  Created by Tibor Bodecs on 2025. 01. 21..
//

public struct Relation {

    public let references: String
    public let type: RelationType
    public let order: Order?

    public init(
        references: String,
        type: RelationType,
        order: Order? = nil
    ) {
        self.references = references
        self.type = type
        self.order = order
    }
}
