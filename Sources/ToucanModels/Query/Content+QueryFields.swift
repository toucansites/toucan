//
//  File.swift
//  toucan
//
//  Created by Tibor Bodecs on 2025. 01. 31..
//

public extension Content {

    var queryFields: [String: AnyCodable] {
        var fields = properties

        for (key, relation) in relations {
            switch relation.type {
            case .one:
                if relation.identifiers.isEmpty {
                    fields[key] = .init([])
                    
                } else {
                    fields[key] = .init(relation.identifiers[0])
                }
            case .many:
                fields[key] = .init(relation.identifiers)
            }
        }

        // add some other fields explicitly
        fields["id"] = .init(id)
        fields["slug"] = .init(slug)
        fields["lastUpdate"] = .init(rawValue.lastModificationDate)
        fields["iterator"] = .init(isIterator)

        return fields
    }
}
