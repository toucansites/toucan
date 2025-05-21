//
//  Settings.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 02. 11..
//

/// A custom coding key type for encoding and decoding dynamic keys.
private struct DynamicCodingKeys: CodingKey {

    var stringValue: String
    var intValue: Int? { return nil }

    init?(stringValue: String) {
        self.stringValue = stringValue
    }

    init?(intValue: Int) {
        return nil
    }
}

/// Represents site-wide configuration settings, allowing for dynamic, user-defined values.
public struct Settings: Codable, Equatable {

    /// A dictionary holding arbitrary user-defined settings keyed by strings.
    public var values: [String: AnyCodable]

    // MARK: - Initialization

    /// The default, empty settings instance.
    public static var defaults: Self {
        .init([:])
    }

    /// Creates a new `Settings` instance with the specified key-value pairs.
    ///
    /// - Parameter values: A dictionary of custom settings.
    public init(
        _ values: [String: AnyCodable]
    ) {
        self.values = values
    }

    // MARK: - Decoding Logic

    /// Initializes a `Settings` instance by decoding from the given decoder.
    ///
    /// If decoding fails, initializes with default empty settings.
    ///
    /// - Parameter decoder: The decoder to read data from.
    /// - Throws: An error if decoding fails unexpectedly.
    public init(
        from decoder: any Decoder
    ) throws {
        guard
            let container = try? decoder.singleValueContainer(),
            let value = try? container.decode([String: AnyCodable].self)
        else {
            self.values = Self.defaults.values
            return
        }
        self.values = value
    }

    /// Encodes the `Settings` instance into the given encoder.
    ///
    /// - Parameter encoder: The encoder to write data to.
    /// - Throws: An error if any value fails to encode.
    public func encode(
        to encoder: any Encoder
    ) throws {
        var container = encoder.container(keyedBy: DynamicCodingKeys.self)
        for (key, value) in values {
            guard let codingKey = DynamicCodingKeys(stringValue: key) else {
                continue
            }
            try container.encode(value, forKey: codingKey)
        }
    }

}
