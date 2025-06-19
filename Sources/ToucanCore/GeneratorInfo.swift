//
//  GeneratorInfo.swift
//  Toucan
//
//  Created by Viasz-Kádi Ferenc on 2025. 03. 19..
//

/// Metadata describing the content generator, including its name, version, and homepage link.
public struct GeneratorInfo: Codable, Sendable {

    /// The name of the generator.
    public let name: String

    /// The version string (e.g., `"1.0.0"`, `"1.0.0-beta.4"`).
    public let version: String

    /// A URL pointing to the generator’s homepage or documentation.
    public let link: String

    // MARK: - Lifecycle

    /// Initializes a generator metadata instance.
    ///
    /// - Parameters:
    ///   - name: The name of the generator (defaults to `"Toucan"`).
    ///   - version: The generator version string.
    ///   - link: A link to the project or documentation (defaults to GitHub).
    init(
        name: String = "Toucan",
        version: String,
        link: String = "https://github.com/toucansites/toucan"
    ) {
        self.name = name
        self.version = version
        self.link = link
    }
}

public extension GeneratorInfo {
    /// Returns the most current version of the generator.
    static var current: Self {
        .v1_0_0_beta_5
    }
}

// list versions here
extension GeneratorInfo {
    static let v1_0_0 = GeneratorInfo(version: "1.0.0")
    static let v1_0_0_rc_1 = GeneratorInfo(version: "1.0.0-rc.1")
    static let v1_0_0_beta_5 = GeneratorInfo(version: "1.0.0-beta.5")
    static let v1_0_0_beta_4 = GeneratorInfo(version: "1.0.0-beta.4")
    static let v1_0_0_beta_3 = GeneratorInfo(version: "1.0.0-beta.3")
    static let v1_0_0_beta_2 = GeneratorInfo(version: "1.0.0-beta.2")
    static let v1_0_0_beta_1 = GeneratorInfo(version: "1.0.0-beta.1")
}
