//
//  File.swift
//  toucan
//
//  Created by Tibor Bodecs on 2025. 01. 31..
//

import ToucanModels

public struct Property {

    public let type: PropertyType
    public let required: Bool
    public let `default`: Any?

    public init(
        type: PropertyType,
        required: Bool,
        `default`: Any? = nil
    ) {
        self.type = type
        self.required = required
        self.`default` = `default`
    }
}

extension Property: Decodable {

    enum CodingKeys: CodingKey {
        case `type`
        case `required`
        case `default`
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(PropertyType.self, forKey: .type)
        let required =
            try container.decodeIfPresent(Bool.self, forKey: .required) ?? true

        self.init(
            type: type,
            required: required,
            default: nil
        )
    }
}
