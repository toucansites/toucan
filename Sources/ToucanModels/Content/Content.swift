//
//  pagebundle.swift
//  TestApp
//
//  Created by Tibor Bodecs on 2025. 01. 15..
//

import ToucanCodable

public struct Content {

    public var rawValue: RawContent
    // identifier is always a string value, relation ids also always strings.
    // local identifier within a type for relations
    public var id: String
    public var slug: String
    public var definition: ContentDefinition
    public var properties: [String: AnyCodable]
    public var relations: [String: RelationValue]
    public var userDefined: [String: AnyCodable]

    public init(
        id: String,
        slug: String,
        rawValue: RawContent,
        definition: ContentDefinition,
        properties: [String: AnyCodable],
        relations: [String: RelationValue],
        userDefined: [String: AnyCodable]
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
