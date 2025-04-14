//
//  Content+QueryFields.swift
//  Toucan
//
//  Created by Tibor Bodecs on 2025. 01. 31..
//

public extension Content {

    var queryFields: [String: AnyCodable] {
        var fields = properties
        for (key, relation) in relations {
            if let identifiers = relation.identifiers {
                fields[key] = identifiers
            }
        }

        // add some other fields explicitly
        fields["id"] = .init(id)
        fields["slug"] = .init(slug.value)
        fields["lastUpdate"] = .init(rawValue.lastModificationDate)
        fields["iterator"] = .init(isIterator)

        return fields
    }
}
