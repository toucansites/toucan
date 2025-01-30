//
//  pagebundle.swift
//  TestApp
//
//  Created by Tibor Bodecs on 2025. 01. 15..
//

public struct Content {

    public var rawValue: RawContent
    public var properties: [String: PropertyValue]
    public var relations: [String: RelationValue]
    public var userDefined: [String: Any]

    public init(
        rawValue: RawContent,
        properties: [String: PropertyValue],
        relations: [String: RelationValue],
        userDefined: [String: Any]
    ) {
        self.rawValue = rawValue
        self.properties = properties
        self.relations = relations
        self.userDefined = userDefined
    }

}
