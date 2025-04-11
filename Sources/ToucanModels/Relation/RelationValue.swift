//
//  RelationValue.swift
//  Toucan
//
//  Created by Tibor Bodecs on 2025. 01. 30..
//

public struct RelationValue {

    public var contentType: String
    public var type: RelationType
    public var identifiers: [Any]

    public init(
        contentType: String,
        type: RelationType,
        identifiers: [Any]
    ) {
        self.contentType = contentType
        self.type = type
        self.identifiers = identifiers
    }
}
