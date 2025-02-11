//
//  File.swift
//  toucan
//
//  Created by Tibor Bodecs on 2025. 01. 31..
//

import ToucanModels

extension Property: Decodable {

    enum CodingKeys: CodingKey {
        case `required`
        case `default`
    }

    public init(from decoder: any Decoder) throws {
        let type = try decoder.singleValueContainer().decode(PropertyType.self)

        let container = try decoder.container(keyedBy: CodingKeys.self)

        // TODO: decide if required is true or false by default
        let required =
            try container.decodeIfPresent(
                Bool.self,
                forKey: .required
            ) ?? true

        let anyValue = try container.decodeIfPresent(
            AnyValue.self,
            forKey: .default
        )

        self.init(
            type: type,
            required: required,
            default: anyValue?.value
        )
    }
}
