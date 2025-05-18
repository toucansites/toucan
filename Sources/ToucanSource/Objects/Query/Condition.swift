//
//  Condition.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 01. 21..
//

/// Represents a logical condition used to filter content during a query.
///
/// `Condition` supports both field-based comparisons and compound logic (AND/OR),
/// and can be resolved dynamically with parameters at runtime.
public enum Condition: Codable, Equatable {

    /// A condition that compares a content field to a value using an operator.
    case field(key: String, operator: Operator, value: AnyCodable)

    /// A logical AND of multiple conditions (all must be true).
    case and([Condition])

    /// A logical OR of multiple conditions (at least one must be true).
    case or([Condition])

    // MARK: - Internal Keys for Decoding

    private enum CodingKeys: CodingKey {
        case key
        case `operator`
        case value
        case and
        case or
    }

    // MARK: - Decoding

    /// Decodes a `Condition` from a decoder, supporting `.field`, `.and`, and `.or` branches.
    ///
    /// Throws a decoding error if none of the known variants are valid in the input.
    public init(
        from decoder: any Decoder
    ) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let key = try? container.decode(String.self, forKey: .key),
            let op = try? container.decode(Operator.self, forKey: .operator),
            let anyValue = try? container.decode(
                AnyCodable.self,
                forKey: .value
            )
        {
            self = .field(key: key, operator: op, value: anyValue)
        }
        else if let values = try? container.decode(
            [Condition].self,
            forKey: .and
        ) {
            self = .and(values)
        }
        else if let values = try? container.decode(
            [Condition].self,
            forKey: .or
        ) {
            self = .or(values)
        }
        else {
            throw DecodingError.dataCorrupted(
                .init(
                    codingPath: decoder.codingPath,
                    debugDescription: "Invalid data for the Condition type."
                )
            )
        }
    }

    public func encode(
        to encoder: Encoder
    ) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case let .field(key, op, value):
            try container.encode(key, forKey: .key)
            try container.encode(op, forKey: .operator)
            try container.encode(value, forKey: .value)
        case let .and(conditions):
            try container.encode(conditions, forKey: .and)
        case let .or(conditions):
            try container.encode(conditions, forKey: .or)
        }
    }
}
