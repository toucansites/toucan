//
//  IteratorInfo.swift
//
//  Created by gerp83 on 2025. 04. 03.
//
    
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

