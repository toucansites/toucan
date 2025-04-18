//
//  Content.swift
//  Toucan
//
//  Created by Tibor Bodecs on 2025. 01. 15..
//

/// Represents a unit of structured content, with associated metadata, relationships, and rendering information.
public struct Content {

    // MARK: - Core Identifiers

    /// A globally unique string identifier for this content item.
    /// This value remains constant across contexts and is used for persistence or lookup.
    public var id: String

    /// A URL-friendly slug that identifies the content in paths or links.
    public var slug: Slug

    /// The raw content representation, usually Markdown or HTML source.
    public var rawValue: RawContent

    /// The content type definition that describes structure and expected fields.
    public var definition: ContentDefinition

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

    /// A computed flag indicating whether this content instance was generated via iteration.
    public var isIterator: Bool { iteratorInfo != nil }

    // MARK: - Initialization

    /// Initializes a new `Content` instance.
    ///
    /// - Parameters:
    ///   - id: A unique identifier.
    ///   - slug: A human-readable URL slug.
    ///   - rawValue: The unparsed content.
    ///   - definition: Structural schema for this content.
    ///   - properties: Parsed content fields.
    ///   - relations: Links to other content.
    ///   - userDefined: Freeform or plugin-provided metadata.
    ///   - iteratorInfo: Optional info for repeated or generated content.
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
