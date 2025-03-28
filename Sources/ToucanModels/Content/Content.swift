//
//  pagebundle.swift
//  TestApp
//
//  Created by Tibor Bodecs on 2025. 01. 15..
//

public struct Content {

    public struct IteratorInfo {

        public struct Link: Codable {
            public var number: Int
            public var permalink: String
            public var isCurrent: Bool

            public init(
                number: Int,
                permalink: String,
                isCurrent: Bool
            ) {
                self.number = number
                self.permalink = permalink
                self.isCurrent = isCurrent
            }
        }

        public var current: Int
        public var total: Int
        public var limit: Int

        public var items: [Content]
        public var links: [Link]

        public var scope: String?

        public init(
            current: Int,
            total: Int,
            limit: Int,
            items: [Content],
            links: [Link],
            scope: String?
        ) {
            self.current = current
            self.total = total
            self.limit = limit
            self.items = items
            self.links = links
            self.scope = scope
        }
    }

    // identifier is always a string value, relation ids also always strings.
    // local identifier within a type for relations
    public var id: String
    public var slug: String
    public var rawValue: RawContent
    public var definition: ContentDefinition
    public var properties: [String: AnyCodable]
    public var relations: [String: RelationValue]
    public var userDefined: [String: AnyCodable]
    public var iteratorInfo: IteratorInfo?

    public var isIterator: Bool { iteratorInfo != nil }

    public init(
        id: String,
        slug: String,
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
