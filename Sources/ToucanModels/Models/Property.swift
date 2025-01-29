//
//  File.swift
//  ToucanV2
//
//  Created by Tibor Bodecs on 2025. 01. 21..
//

public struct Property {

    public let key: String
    public let type: DataType
    public let required: Bool
    public let `default`: Any?

    public init(
        key: String,
        type: DataType,
        required: Bool,
        `default`: Any? = nil
    ) {
        self.key = key
        self.type = type
        self.required = required
        self.`default` = `default`
    }
}
