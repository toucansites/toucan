//
//  File.swift
//  Toucan
//
//  Created by Tibor Bodecs on 2025. 01. 21..
//

public struct Property: Decodable, Equatable {

    enum CodingKeys: CodingKey {
        case `required`
        case `default`
    }

    public var `type`: PropertyType
    /// Required, defaults to  true
    public var `required`: Bool
    public var `default`: AnyCodable?

    // MARK: - init

    public init(
        `type`: PropertyType,
        `required`: Bool,
        `default`: AnyCodable? = nil
    ) {
        self.`type` = `type`
        self.`required` = `required`
        self.`default` = `default`
    }

    // MARK: - decoder

    public init(from decoder: any Decoder) throws {
        let type = try decoder.singleValueContainer().decode(PropertyType.self)

        let container = try decoder.container(keyedBy: CodingKeys.self)

        let required =
            try container.decodeIfPresent(
                Bool.self,
                forKey: .required
            ) ?? true

        let anyValue = try container.decodeIfPresent(
            AnyCodable.self,
            forKey: .default
        )

        self.init(
            type: type,
            required: required,
            default: anyValue
        )
    }
}
