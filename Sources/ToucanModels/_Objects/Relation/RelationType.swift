//
//  RelationType.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 01. 21..
//

/// Defines the cardinality of a content relation, indicating whether it links to one or multiple items.
public enum RelationType: String, Decodable, Equatable {

    /// A one-to-one relation. The relation targets a single content item.
    case one

    /// A one-to-many relation. The relation targets a collection of content items.
    case many
}
