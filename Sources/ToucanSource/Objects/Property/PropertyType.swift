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

    /// Date type with optional localized formatting.
    case date(format: LocalizedDateFormat?)

    /// Array type with elements of a consistent `PropertyType`.
    case array(of: PropertyType)

    /// Coding keys used for encoding and decoding `PropertyType`.
    private enum CodingKeys: String, CodingKey {
        case of
        case type
        case dateFormat
    }

    /// Type discriminator used during encoding and decoding.
    private enum TypeKey: String, Sendable, Codable, Equatable, CaseIterable {
        case bool
        case int
        case double
        case string
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
        case .date:
            let format = try container.decodeIfPresent(
                LocalizedDateFormat.self,
                forKey: .dateFormat
            )
            self = .date(format: format)
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
        case .date(let format):
            try container.encode(TypeKey.date, forKey: .type)
            try container.encodeIfPresent(format, forKey: .dateFormat)
        case .array(let of):
            try container.encode(TypeKey.array, forKey: .type)
            try container.encode(of, forKey: .of)
        }
    }
}
