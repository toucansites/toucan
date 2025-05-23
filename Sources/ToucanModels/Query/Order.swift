//
//  Order.swift
//  Toucan
//
//  Created by Tibor Bodecs on 2025. 01. 15..
//

/// Represents a sorting rule for ordering content query results.
///
/// Each `Order` defines a content field to sort by and the direction of sorting.
public struct Order: Decodable, Equatable {

    // MARK: - Coding Keys

    /// Keys used for decoding an `Order` from external sources (e.g., YAML, JSON).
    enum CodingKeys: CodingKey {
        case key
        case direction
    }

    // MARK: - Properties

    /// The name of the field to sort by (e.g., `"date"`, `"title"`, `"priority"`).
    public var key: String

    /// The direction to sort the field (`asc` or `desc`).
    public var direction: Direction

    // MARK: - Initialization

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

    // MARK: - Decoding

    /// Decodes an `Order` from a decoder.
    ///
    /// If the `direction` field is missing, it defaults to `.asc`.
    public init(from decoder: any Decoder) throws {
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
}
