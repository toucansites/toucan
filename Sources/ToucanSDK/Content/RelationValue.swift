//
//  RelationValue.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 01. 30..
//

import ToucanSource

/// Represents the resolved value of a relation in content, including the target content type,
/// the relation's cardinality, and the identifiers of related items.
public struct RelationValue {

    /// The type of content this relation points to (e.g., `"author"`, `"post"`, `"product"`).
    public var contentType: String

    /// The relation type indicating if it's a one-to-one or one-to-many relationship.
    public var type: RelationType

    /// A list of string identifiers for the related content items.
    /// For `.one`, this should typically contain a single ID; for `.many`, multiple.
    public var identifiers: [String]

    /// Initializes a new `RelationValue` representing the resolved target(s) of a content relation.
    ///
    /// - Parameters:
    ///   - contentType: The name of the target content type.
    ///   - type: The type of relation (single or multiple).
    ///   - identifiers: A list of string IDs pointing to related content.
    public init(
        contentType: String,
        type: RelationType,
        identifiers: [String]
    ) {
        self.contentType = contentType
        self.type = type
        self.identifiers = identifiers
    }
}
