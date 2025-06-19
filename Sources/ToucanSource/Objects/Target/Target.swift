//
//  Target.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 05. 15..
//

/// Represents a deployment target configuration for a Toucan project.
public struct Target: Codable, Equatable {

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

    /// Base values used when decoding fails or fields are missing.
    private static var base: Self {
        .init(
            name: "dev",
            config: "",
            url: "http://localhost:3000",
            output: "docs",
            isDefault: false
        )
    }

    /// Standard target value
    public static var standard: Self {
        var target = Self.base
        target.isDefault = true
        return target
    }

    /// The unique name of the target.
    public var name: String

    /// The path to the configuration file.
    public var config: String

    /// The base URL of the site or project without a trailing slash (e.g., `"https://example.com"`).
    public var url: String

    /// The output path for generated files.
    public var output: String

    /// A flag indicating if this is the default target.
    public var isDefault: Bool

    /// Creates a new target configuration.
    /// - Parameters:
    ///   - name: The unique name of the target.
    ///   - config: The path to the configuration file.
    ///   - url: The base URL for the target.
    ///   - output: The output path for generated files.
    ///   - isDefault: A flag indicating if this is the default target.
    public init(
        name: String,
        config: String,
        url: String,
        output: String,
        isDefault: Bool
    ) {
        self.name = name
        self.config = config
        self.url = url
        self.output = output
        self.isDefault = isDefault
    }

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
            ) ?? base.url

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
        try container.encode(output, forKey: .output)
        try container.encode(isDefault, forKey: .default)
    }
}
