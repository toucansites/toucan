//
//  File.swift
//  toucan
//
//  Created by Tibor Bodecs on 2025. 01. 30..
//

public struct RelationValue {

    public var contentType: String
    public var type: RelationType
    public var identifiers: [String]

    public init(
        contentType: String,
        type: RelationType,
        identifiers: [String]
    ) {
        self.contentType = contentType
        self.type = type
        self.identifiers = identifiers
    }
}
