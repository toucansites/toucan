//
//  Relation.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 01. 21..
//

/// Represents a relationship between a content item and one or more other content items.
///
/// A `Relation` defines how content items are connected, such as linking a blog post
/// to its author or related articles. It includes the type of relation,
/// reference key(s), and optional ordering rules.
public struct Relation: Codable, Equatable {
    // MARK: - Coding Keys

    /// Keys used to decode the relation from serialized formats like JSON or YAML.
    enum CodingKeys: CodingKey {
        case references
        case type
        case order
    }

    /// The key or query string that identifies the related content.
    ///
    /// This might represent a single ID, a tag filter, or a content type to resolve.
    public var references: String

    /// The type of relation, describing how the content is linked (e.g., one-to-one, many-to-one).
    public var type: RelationType

    /// Optional sorting logic to apply to related content (e.g., by date or title).
    public var order: Order?

    // MARK: - Initialization

    /// Creates a new `Relation` instance with required and optional properties.
    ///
    /// - Parameters:
    ///   - references: A string identifying the target or criteria for the relation.
    ///   - relationType: The relation type (e.g., `.single`, `.collection`).
    ///   - order: Optional sorting rules for related content.
    public init(
        references: String,
        relationType: RelationType,
        order: Order? = nil
    ) {
        self.references = references
        self.type = relationType
        self.order = order
    }

    // MARK: - Decoding

    /// Decodes a `Relation` from a decoder, applying custom key mapping and optional logic.
    ///
    /// This ensures that all fields are safely extracted and defaults applied if necessary.
    public init(
        from decoder: any Decoder
    ) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let references = try container.decode(String.self, forKey: .references)
        let type = try container.decode(RelationType.self, forKey: .type)
        let order = try container.decodeIfPresent(Order.self, forKey: .order)

        self.init(
            references: references,
            relationType: type,
            order: order
        )
    }
}
