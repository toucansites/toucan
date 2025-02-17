//
//  File.swift
//  toucan
//
//  Created by Tibor Bodecs on 2025. 01. 31..
//

import Foundation
import ToucanModels
import ToucanCodable

extension Content {

    // relations can be queried too
    // TODO: maybe add support for user defined values?
    var queryFields: [String: AnyCodable] {
        var fields = properties

        for (key, relation) in relations {
            switch relation.type {
            case .one:
                fields[key] = .init(relation.identifiers[0])
            case .many:
                fields[key] = .init(relation.identifiers)
            }
        }

        // add identifier & slug explicitly
        fields["id"] = .init(id)
        fields["slug"] = .init(slug)
        fields["lastModificationDate"] = .init(rawValue.lastModificationDate)
        return fields
    }
}
