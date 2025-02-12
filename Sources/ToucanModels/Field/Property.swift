//
//  File.swift
//  ToucanV2
//
//  Created by Tibor Bodecs on 2025. 01. 21..
//

import ToucanCodable

public struct Property {

    public let type: PropertyType
    public let required: Bool
    public let `default`: AnyCodable?

    public init(
        type: PropertyType,
        required: Bool,
        `default`: AnyCodable? = nil
    ) {
        self.type = type
        self.required = required
        self.`default` = `default`
    }
}
