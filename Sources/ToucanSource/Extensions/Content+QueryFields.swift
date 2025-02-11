//
//  File.swift
//  toucan
//
//  Created by Tibor Bodecs on 2025. 01. 31..
//

import Foundation
import ToucanModels

extension Content {

    // relations can be queried too
    // TODO: maybe add support for user defined values?
    var queryFields: [String: AnyValue] {
        var fields = properties

        for (key, relation) in relations {
            switch relation.type {
            case .one:
                fields[key] = .init(value: relation.identifiers[0])
            case .many:
                fields[key] = .init(value: relation.identifiers)
            }
        }

        // add identifier & slug explicitly
        fields["id"] = .init(value: id)
        fields["slug"] = .init(value: slug)
        return fields
    }
}
