//
//  Property.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 01. 21..
//

/// Represents a single content property definition, including its type,
/// whether it's required, and an optional default value.
public struct Property: Decodable, Equatable {

    /// Coding keys used for decoding optional metadata fields.
    enum CodingKeys: CodingKey {
        case `required`
        case `default`
    }

    /// The type of the property (e.g., string, number, boolean, etc.).
    public var `type`: PropertyType

    /// Whether the property is required in the content entry.
    ///
    /// Defaults to `true` if not explicitly provided in the definition.
    public var `required`: Bool

    /// An optional default value to use if the property is missing in the content.
    public var `default`: AnyCodable?

    // MARK: - Initialization

    /// Initializes a new `Property` definition.
    ///
    /// - Parameters:
    ///   - propertyType: The declared type of the property.
    ///   - isRequired: Whether the field must be present in content. Defaults to `true` if not specified during decoding.
    ///   - defaultValue: An optional default value to use if the content omits this property.
    public init(
        propertyType: PropertyType,
        isRequired: Bool,
        defaultValue: AnyCodable? = nil
    ) {
        self.`type` = propertyType
        self.`required` = isRequired
        self.`default` = defaultValue
    }

    // MARK: - Decoding

    /// Decodes a `Property` from a serialized representation, handling both the
    /// core type and optional metadata (required flag and default value).
    ///
    /// If the `required` field is missing, it defaults to `true`.
    public init(from decoder: any Decoder) throws {
        let type = try decoder.singleValueContainer().decode(PropertyType.self)

        let container = try decoder.container(keyedBy: CodingKeys.self)

        let required =
            try container.decodeIfPresent(Bool.self, forKey: .required) ?? true

        let anyValue = try container.decodeIfPresent(
            AnyCodable.self,
            forKey: .default
        )

        self.init(
            propertyType: type,
            isRequired: required,
            defaultValue: anyValue
        )
    }
}
