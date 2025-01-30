//
//  File.swift
//  toucan
//
//  Created by Tibor Bodecs on 2025. 01. 30..
//

public struct RelationValue {

    public var contentType: String
    public var type: RelationType
    public var values: [PropertyValue]

    public init(
        contentType: String,
        type: RelationType,
        values: [PropertyValue]
    ) {
        self.contentType = contentType
        self.type = type
        self.values = values
    }
}
