//
//  PropertyType.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 01. 21..
//

/// Represents the type of a content property.
///
/// Used in defining content schemas or type-safe metadata fields.
/// Supports primitive types (`bool`, `int`, `double`, `string`, `date`)
/// and complex structures like arrays of types.
public indirect enum PropertyType: Sendable, Codable, Equatable {
    /// Boolean type (`true` or `false`).
    case bool

    /// Integer type (`Int`).
    case int

    /// Floating-point number type (`Double`).
    case double

    /// Text/string type (`String`).
    case string

    /// Asset reference stored as a string value
    case asset

    /// Date type with optional localized formatting.
    case date(config: DateFormatterConfig?)

    /// Array type with elements of a consistent `PropertyType`.
    case array(of: PropertyType)

    /// Coding keys used for encoding and decoding `PropertyType`.
    private enum CodingKeys: String, CodingKey {
        case type
        // date input config
        case config
        // type of array elements
        case of
    }

    /// Type discriminator used during encoding and decoding.
    private enum TypeKey: String, Sendable, Codable, Equatable, CaseIterable {
        case bool
        case int
        case double
        case string
        case asset
        case date
        case array
    }

    /// Creates a new instance by decoding from the given decoder.
    ///
    /// Supports primitive and nested types with optional date formatting.
    ///
    /// - Parameter decoder: The decoder to read data from.
    /// - Throws: An error if decoding fails.
    public init(
        from decoder: Decoder
    ) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(TypeKey.self, forKey: .type)

        switch type {
        case .bool:
            self = .bool
        case .int:
            self = .int
        case .double:
            self = .double
        case .string:
            self = .string
        case .asset:
            self = .asset
        case .date:
            let config = try container.decodeIfPresent(
                DateFormatterConfig.self,
                forKey: .config
            )
            self = .date(config: config)
        case .array:
            let itemType = try container.decode(PropertyType.self, forKey: .of)
            self = .array(of: itemType)
        }
    }

    /// Encodes this value into the given encoder.
    ///
    /// - Parameter encoder: The encoder to write data to.
    /// - Throws: An error if encoding fails.
    public func encode(
        to encoder: Encoder
    ) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .bool:
            try container.encode(TypeKey.bool, forKey: .type)
        case .int:
            try container.encode(TypeKey.int, forKey: .type)
        case .double:
            try container.encode(TypeKey.double, forKey: .type)
        case .string:
            try container.encode(TypeKey.string, forKey: .type)
        case .asset:
            try container.encode(TypeKey.asset, forKey: .type)
        case let .date(config):
            try container.encode(TypeKey.date, forKey: .type)
            try container.encodeIfPresent(config, forKey: .config)
        case let .array(of):
            try container.encode(TypeKey.array, forKey: .type)
            try container.encode(of, forKey: .of)
        }
    }
}
