//
//  Content.swift
//  Toucan
//
//  Created by Tibor Bodecs on 2025. 01. 15..
//

public struct Content {

    // identifier is always a string value, relation ids also always strings.
    // local identifier within a type for relations
    public var id: String
    public var slug: Slug
    public var rawValue: RawContent
    public var definition: ContentDefinition
    public var properties: [String: AnyCodable]
    public var relations: [String: RelationValue]
    public var userDefined: [String: AnyCodable]
    public var iteratorInfo: IteratorInfo?
    public var isIterator: Bool { iteratorInfo != nil }

    public init(
        id: String,
        slug: Slug,
        rawValue: RawContent,
        definition: ContentDefinition,
        properties: [String: AnyCodable],
        relations: [String: RelationValue],
        userDefined: [String: AnyCodable],
        iteratorInfo: IteratorInfo?
    ) {
        self.id = id
        self.slug = slug
        self.rawValue = rawValue
        self.definition = definition
        self.properties = properties
        self.relations = relations
        self.userDefined = userDefined
        self.iteratorInfo = iteratorInfo
    }
}
