//
//  File.swift
//  ToucanV2
//
//  Created by Tibor Bodecs on 2025. 01. 21..
//

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
