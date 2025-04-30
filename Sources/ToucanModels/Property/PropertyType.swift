//
//  PropertyType.swift
//  Toucan
//
//  Created by Tibor Bodecs on 2025. 01. 21..
//

/// Represents the type of a content property, used in defining content schemas or type-safe metadata fields.
///
/// Supports primitive types (`bool`, `int`, `double`, `string`, `date`) and nested structures like arrays of types.
public indirect enum PropertyType: Decodable, Equatable {

    /// A Boolean property type (`true` or `false`).
    case bool

    /// An integer property type (`Int`).
    case int

    /// A double/decimal number property type (`Double`).
    case double

    /// A string/text property type (`String`).
    case string

    /// A date property type with optional localized formatting.
    case date(format: LocalizedDateFormat?)

    /// An array of values with a consistent inner property type.
    case array(of: PropertyType)

    // MARK: - Internal Coding Keys

    private enum CodingKeys: String, CodingKey {
        case of
        case type
        case dateFormat
    }

    /// Recognized type tags for decoding.
    private enum TypeKey: String, Decodable {
        case bool
        case int
        case double
        case string
        case date
        case array
    }

    // MARK: - Decoder

    /// Decodes a `PropertyType` from a structured definition.
    ///
    /// Supports nested types for arrays and optional date formatting.
    ///
    /// - Throws: A decoding error if required keys are missing or invalid.
    public init(from decoder: Decoder) throws {
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
}
