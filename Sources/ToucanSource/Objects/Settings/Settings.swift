//
//  Settings.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 02. 11..
//

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

/// Represents site  settings.
public struct Settings: Codable, Equatable {

    /// A dictionary of user-defined settings values.
    public var values: [String: AnyCodable]

    // MARK: - Initialization

    /// Standard settings value
    public static var defaults: Self {
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
            self.values = Self.defaults.values
            return
        }
        self.values = value
    }

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
