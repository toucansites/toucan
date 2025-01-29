//
//  File.swift
//  ToucanV2
//
//  Created by Tibor Bodecs on 2025. 01. 21..
//

// TODO: join?
public struct Relation {

    public let key: String
    public let references: String
    public let type: RelationType
    public let order: Order?
    
    public init(
        key: String,
        references: String,
        type: RelationType,
        order: Order? = nil
    ) {
        self.key = key
        self.references = references
        self.type = type
        self.order = order
    }
}
