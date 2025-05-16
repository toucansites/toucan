//
//  Target.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 05. 15..
//

/// Represents a deployment target configuration for a Toucan project.
public struct Target: Codable, Equatable {

    // MARK: - Coding Keys

    /// Keys explicitly defined for decoding known fields from the input source.
    enum CodingKeys: CodingKey, CaseIterable {
        case name
        case config
        case url
        case locale
        case timeZone
        case output
        case `default`
    }

    // MARK: - Properties

    /// The unique name of the target.
    public var name: String

    /// The path to the configuration file.
    public var config: String

    /// The base URL of the site or project without a trailing slash (e.g., `"https://example.com"`).
    public var url: String

    /// The locale identifier used for date/time formatting and content localization (e.g., `"en-US"`).
    public var locale: String

    /// The time zone used for formatting timestamps (e.g., `"UTC"`, `"Europe/Berlin"`).
    public var timeZone: String

    /// The output path for generated files.
    public var output: String

    /// A flag indicating if this is the default target.
    public var isDefault: Bool

    // MARK: - Defaults

    /// Standard target value
    public static var standard: Self {
        var target = Self.base
        target.isDefault = true
        return target
    }

    /// Base values used when decoding fails or fields are missing.
    private static var base: Self {
        .init(
            name: "dev",
            config: "",
            url: "http://localhost:3000",
            locale: "en-US",
            timeZone: "UTC",
            output: "docs",
            isDefault: false
        )
    }

    // MARK: - Initialization

    /// Creates a new target configuration.
    /// - Parameters:
    ///   - name: The unique name of the target.
    ///   - config: The path to the configuration file.
    ///   - url: The base URL for the target.
    ///   - locale: The locale identifier for the target.
    ///   - timeZone: The time zone identifier.
    ///   - output: The output path for generated files.
    ///   - isDefault: A flag indicating if this is the default target.
    public init(
        name: String,
        config: String,
        url: String,
        locale: String,
        timeZone: String,
        output: String,
        isDefault: Bool
    ) {
        self.name = name
        self.config = config
        self.url = url.dropTrailingSlash()
        self.locale = locale
        self.timeZone = timeZone
        self.output = output
        self.isDefault = isDefault
    }

    // MARK: - Decoding Logic

    /// Custom decoder with fallback values.
    public init(
        from decoder: any Decoder
    ) throws {
        let base = Self.base

        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.name =
            try container.decodeIfPresent(String.self, forKey: .name)
            ?? base.name

        self.config =
            try container.decodeIfPresent(String.self, forKey: .config)
            ?? base.config

        self.url =
            try container
            .decodeIfPresent(
                String.self,
                forKey: .url
            )?
            .dropTrailingSlash() ?? base.url.dropTrailingSlash()

        self.locale =
            try container.decodeIfPresent(String.self, forKey: .locale)
            ?? base.locale

        self.timeZone =
            try container.decodeIfPresent(String.self, forKey: .timeZone)
            ?? base.timeZone

        self.output =
            try container.decodeIfPresent(String.self, forKey: .output)
            ?? base.output

        self.isDefault =
            try container.decodeIfPresent(Bool.self, forKey: .default)
            ?? base.isDefault
    }

    /// Encodes this instance into the given encoder.
    ///
    /// - Parameter encoder: The encoder to write data to.
    /// - Throws: An error if any values are invalid for the given encoder’s format.
    public func encode(
        to encoder: any Encoder
    ) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(name, forKey: .name)
        try container.encode(config, forKey: .config)
        try container.encode(url, forKey: .url)
        try container.encodeIfPresent(locale, forKey: .locale)
        try container.encodeIfPresent(timeZone, forKey: .timeZone)
        try container.encode(output, forKey: .output)
        try container.encode(isDefault, forKey: .default)
    }
}
