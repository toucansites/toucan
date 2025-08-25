//
//  Order.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 01. 15..
//

/// Represents a sorting rule for ordering content query results.
///
/// Each `Order` defines a content field to sort by and the direction of sorting.
public struct Order: Sendable, Codable, Equatable {

    /// Internal keys used for encoding and decoding `Order` instances.
    /// Keys used for decoding an `Order` from external sources (e.g., YAML, JSON).
    enum CodingKeys: CodingKey, CaseIterable {
        case key
        case direction
    }

    /// The name of the field to sort by (e.g., `"date"`, `"title"`, `"priority"`).
    public var key: String

    /// The direction to sort the field (`asc` or `desc`).
    public var direction: Direction

    /// Creates a new `Order` instance.
    ///
    /// - Parameters:
    ///   - key: The field name to sort by.
    ///   - direction: The sorting direction. Defaults to `.asc`.
    public init(
        key: String,
        direction: Direction = .asc
    ) {
        self.key = key
        self.direction = direction
    }

    /// Decodes an `Order` from a decoder.
    ///
    /// If the `direction` field is missing, it defaults to `.asc`.
    public init(
        from decoder: any Decoder
    ) throws {
        try decoder.validateUnknownKeys(keyType: CodingKeys.self)

        let container = try decoder.container(keyedBy: CodingKeys.self)
        let key = try container.decode(String.self, forKey: .key)
        let direction =
            try container.decodeIfPresent(Direction.self, forKey: .direction)
            ?? .defaults

        self.init(
            key: key,
            direction: direction
        )
    }

    /// Encodes this `Order` instance into the given encoder.
    ///
    /// - Parameter encoder: The encoder to write data to.
    /// - Throws: An error if encoding fails.
    public func encode(
        to encoder: any Encoder
    ) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(key, forKey: .key)
        try container.encode(direction, forKey: .direction)
    }
}
