//
//  Target.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 05. 15..
//

/// Represents a deployment target configuration for a Toucan project.
public struct Target: Decodable, Equatable {

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

    /// The base URL for the target.
    public var url: String

    /// The locale identifier for the target (e.g., "en-US").
    public var locale: String?

    /// The time zone identifier (e.g., "Europe/Budapest").
    public var timeZone: String?

    /// The output path for generated files.
    public var output: String

    /// A flag indicating if this is the default target.
    public var isDefault: Bool

    // MARK: - Defaults

    /// Default values used when decoding fails or fields are missing.
    public static var `default`: Self {
        var target = Self.defaults
        target.isDefault = true
        return target
    }
    
    /// Default values used when decoding fails or fields are missing.
    public static var `defaults`: Self {
        .init(
            name: "dev",
            config: "./config.yml",
            url: "http://localhost:3000",
            locale: nil,
            timeZone: nil,
            output: "./docs/",
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
        locale: String?,
        timeZone: String?,
        output: String,
        isDefault: Bool
    ) {
        self.name = name
        self.config = config
        self.url = url
        self.locale = locale
        self.timeZone = timeZone
        self.output = output
        self.isDefault = isDefault
    }

    // MARK: - Decoding Logic

    /// Custom decoder with fallback values.
    public init(from decoder: any Decoder) throws {
        let defaults = Self.defaults

        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.name =
            try container.decodeIfPresent(String.self, forKey: .name)
            ?? defaults.name

        self.config =
            try container.decodeIfPresent(String.self, forKey: .config)
            ?? defaults.config

        self.url =
            try container.decodeIfPresent(String.self, forKey: .url)
            ?? defaults.url

        self.locale =
            try container.decodeIfPresent(String.self, forKey: .locale)
            ?? defaults.locale

        self.timeZone =
            try container.decodeIfPresent(String.self, forKey: .timeZone)
            ?? defaults.timeZone

        self.output =
            try container.decodeIfPresent(String.self, forKey: .output)
            ?? defaults.output

        self.isDefault =
            try container.decodeIfPresent(Bool.self, forKey: .default)
            ?? defaults.isDefault
    }
}
