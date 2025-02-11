//
//  pagebundle.swift
//  TestApp
//
//  Created by Tibor Bodecs on 2025. 01. 15..
//

public struct Content {

    public var rawValue: RawContent
    // identifier is always a string value, relation ids also always strings.
    // local identifier within a type for relations
    public var id: String
    public var slug: String
    public var definition: ContentDefinition
    public var properties: [String: AnyValue]
    public var relations: [String: RelationValue]
    public var userDefined: [String: AnyValue]

    public init(
        id: String,
        slug: String,
        rawValue: RawContent,
        definition: ContentDefinition,
        properties: [String: AnyValue],
        relations: [String: RelationValue],
        userDefined: [String: AnyValue]
    ) {
        self.id = id
        self.slug = slug
        self.rawValue = rawValue
        self.definition = definition
        self.properties = properties
        self.relations = relations
        self.userDefined = userDefined
    }
}
