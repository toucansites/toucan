//
//  Settings.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 02. 11..
//

/// Represents site  settings.
public struct Settings: Codable, Equatable {

    /// A dictionary of user-defined settings values.
    public var values: [String: AnyCodable]

    // MARK: - Initialization

    /// Standard settings value
    public static var standard: Self {
        .init([:])
    }

    /// Initializes a new object with explicit values.
    ///
    /// - Parameters values: A dictionary of additional custom settings.
    public init(
        _ values: [String: AnyCodable]
    ) {
        self.values = values
    }

    // MARK: - Decoding Logic

    /// Custom decoder that decodes key-value pairs.
    ///
    /// All keys are captured in the underlying dictionary.
    public init(
        from decoder: any Decoder
    ) throws {
        guard
            let container = try? decoder.singleValueContainer(),
            let value = try? container.decode([String: AnyCodable].self)
        else {
            self.values = Self.standard.values
            return
        }
        self.values = value
    }

}
