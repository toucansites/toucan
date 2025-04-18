//
//  Settings.swift
//  Toucan
//
//  Created by Tibor Bodecs on 2025. 02. 11..
//

/// Represents site-wide configuration settings for a Toucan project,
/// including localization, identification, and custom user-defined fields.
///
/// This struct supports decoding from YAML/JSON and includes fallback defaults
/// for missing or incomplete configurations.
public struct Settings: Decodable, Equatable {

    // MARK: - Coding Keys

    /// Keys explicitly defined for decoding known fields from the input source.
    enum CodingKeys: CodingKey, CaseIterable {
        case baseUrl
        case name
        case locale
        case timeZone
    }

    // MARK: - Properties

    /// The base URL of the site or project (e.g., `"https://example.com"`).
    public var baseUrl: String

    /// The name or title of the site (e.g., `"My Blog"`).
    public var name: String

    /// The locale identifier used for date/time formatting and content localization (e.g., `"en-US"`).
    public var locale: String

    /// The time zone used for formatting timestamps (e.g., `"UTC"`, `"Europe/Berlin"`).
    public var timeZone: String

    /// A dictionary of custom user-defined settings that extend the standard schema.
    public var userDefined: [String: AnyCodable]

    // MARK: - Defaults

    /// Default values used when decoding fails or fields are missing.
    public static var defaults: Self {
        .init(
            baseUrl: "http://localhost:3000",
            name: "localhost",
            locale: "en-US",
            timeZone: "UTC",
            userDefined: [:]
        )
    }

    // MARK: - Initialization

    /// Initializes a new `Settings` object with explicit values.
    ///
    /// - Parameters:
    ///   - baseUrl: The base URL of the site.
    ///   - name: The display name or title of the project.
    ///   - locale: The locale string used for formatting and localization.
    ///   - timeZone: The time zone identifier string.
    ///   - userDefined: A dictionary of additional custom settings.
    public init(
        baseUrl: String,
        name: String,
        locale: String,
        timeZone: String,
        userDefined: [String: AnyCodable]
    ) {
        self.baseUrl = baseUrl.dropTrailingSlash()
        self.name = name
        self.locale = locale
        self.timeZone = timeZone
        self.userDefined = userDefined
    }

    // MARK: - Decoding Logic

    /// Custom decoder that merges standard keys with arbitrary user-defined ones.
    ///
    /// If standard fields are missing, defaults are applied.
    /// All non-standard keys are captured in the `userDefined` dictionary.
    public init(from decoder: any Decoder) throws {
        let defaults = Self.defaults

        // Try decoding the known keys
        guard let container = try? decoder.container(keyedBy: CodingKeys.self)
        else {
            self = defaults
            return
        }

        self.baseUrl =
            try container.decodeIfPresent(String.self, forKey: .baseUrl)?
            .dropTrailingSlash() ?? defaults.baseUrl.dropTrailingSlash()

        self.name =
            try container.decodeIfPresent(String.self, forKey: .name)
            ?? defaults.name

        self.locale =
            try container.decodeIfPresent(String.self, forKey: .locale)
            ?? defaults.locale

        self.timeZone =
            try container.decodeIfPresent(String.self, forKey: .timeZone)
            ?? defaults.timeZone

        // Decode all key-value pairs, then remove the known ones to get user-defined data
        var result = try decoder.singleValueContainer()
            .decode([String: AnyCodable].self)

        for key in CodingKeys.allCases {
            result.removeValue(forKey: key.stringValue)
        }

        self.userDefined = result
    }
}
