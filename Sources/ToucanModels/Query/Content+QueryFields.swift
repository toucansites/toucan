//
//  Content+QueryFields.swift
//  Toucan
//
//  Created by Tibor Bodecs on 2025. 01. 31..
//

public extension Content {

    /// Flattens the content's core properties, relations, and metadata into a single dictionary
    /// for use in filtering, querying, or templating contexts.
    ///
    /// - Includes:
    ///   - All `properties` as defined in the content type
    ///   - Resolved `relations`, where:
    ///     - `.one` types return a single identifier (or an empty array if unresolved)
    ///     - `.many` types return an array of identifiers
    ///   - Additional metadata:
    ///     - `"id"`: The content's unique identifier
    ///     - `"slug"`: The slug string used for URLs
    ///     - `"lastUpdate"`: Last modification timestamp of the content
    ///     - `"iterator"`: Boolean flag indicating if this content is an iterator item
    ///
    /// - Returns: A `[String: AnyCodable]` dictionary representing queryable fields.
    var queryFields: [String: AnyCodable] {
        var fields = properties

        // Flatten relational fields by type
        for (key, relation) in relations {
            switch relation.type {
            case .one:
                if relation.identifiers.isEmpty {
                    // Default to empty array if no target
                    fields[key] = .init([])
                }
                else {
                    fields[key] = .init(relation.identifiers[0])  // Single ID
                }
            case .many:
                fields[key] = .init(relation.identifiers)  // Array of IDs
            }
        }

        // Append metadata fields
        fields["id"] = .init(id)
        fields["slug"] = .init(slug.value)
        fields["lastUpdate"] = .init(rawValue.lastModificationDate)
        fields["iterator"] = .init(isIterator)

        return fields
    }
}
