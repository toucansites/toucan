//
//  Content.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 01. 15..
//

import ToucanSource

/// Represents a unit of structured content, with associated metadata, relationships, and rendering information.
public struct Content {
    // MARK: - Properties

    // MARK: - Core Identifiers

    /// The content type definition that describes structure and expected fields.
    public var type: ContentDefinition

    /// A globally unique string identifier for this content item.
    /// This value remains constant across contexts and is used for persistence or lookup.
    public var typeAwareID: String

    /// A URL-friendly slug that identifies the content in paths or links.
    public var slug: Slug

    /// The raw content representation, usually Markdown or HTML source.
    public var rawValue: RawContent

    // MARK: - Data & Metadata

    /// A dictionary of properties that hold the parsed field values (e.g., title, date, body).
    /// Keys are field names as defined in the `ContentDefinition`, and values are dynamically typed.
    public var properties: [String: AnyCodable]

    /// A dictionary of relations to other content items, keyed by relation name.
    /// The relation values may include identifiers or full references depending on usage.
    public var relations: [String: RelationValue]

    /// Arbitrary user-defined metadata not explicitly declared in the content definition.
    /// These are typically useful for extensibility or plugin features.
    public var userDefined: [String: AnyCodable]

    // MARK: - Iteration Support

    /// Optional iterator metadata if the content is generated through iteration (e.g., paginated or list item).
    public var iteratorInfo: IteratorInfo?

    // MARK: - Computed Properties

    /// A computed flag indicating whether this content instance was generated via iteration.
    public var isIterator: Bool { iteratorInfo != nil }

    // MARK: - Lifecycle

    // MARK: - Initialization

    /// Initializes a new `Content` instance.
    ///
    /// - Parameters:
    ///   - type: Structural schema for this content.
    ///   - typeAwareID: A unique identifier.
    ///   - slug: A human-readable URL slug.
    ///   - rawValue: The unparsed content.
    ///   - properties: Parsed content fields.
    ///   - relations: Links to other content.
    ///   - userDefined: Freeform or plugin-provided metadata.
    ///   - iteratorInfo: Optional info for repeated or generated content.
    public init(
        type: ContentDefinition,
        typeAwareID: String,
        slug: Slug,
        rawValue: RawContent,
        properties: [String: AnyCodable],
        relations: [String: RelationValue],
        userDefined: [String: AnyCodable],
        iteratorInfo: IteratorInfo?
    ) {
        self.type = type
        self.typeAwareID = typeAwareID
        self.slug = slug
        self.rawValue = rawValue
        self.properties = properties
        self.relations = relations
        self.userDefined = userDefined
        self.iteratorInfo = iteratorInfo
    }
}
