//
//  Settings.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 02. 11..
//

/// Represents site-wide configuration settings for a Toucan project,
/// including localization, identification, and custom user-defined fields.
///
/// This struct supports decoding from YAML/JSON and includes fallback defaults
/// for missing or incomplete configurations.
public struct Settings: Decodable, Equatable {

    /// A dictionary of custom user-defined settings that extend the standard schema.
    public var userDefined: [String: AnyCodable]


    // MARK: - Initialization

    /// Initializes a new `Settings` object with explicit values.
    ///
    /// - Parameters:
    ///   - userDefined: A dictionary of additional custom settings.
    public init(
        userDefined: [String: AnyCodable]
    ) {
        self.userDefined = userDefined
    }

    // MARK: - Decoding Logic

    /// Custom decoder that decodes key-value pairs.
    ///
    /// All keys are captured in the underlying dictionary.
    public init(from decoder: any Decoder) throws {
        guard
            let container = try? decoder.singleValueContainer(),
            let value = try? container.decode([String:AnyCodable].self)
        else {
            self.userDefined = [:]
            return
        }
        self.userDefined = value
    }
}
