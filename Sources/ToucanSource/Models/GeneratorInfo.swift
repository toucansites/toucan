//
//  File.swift
//  toucan
//
//  Created by Viasz-Kádi Ferenc on 2025. 03. 19..
//

public struct GeneratorInfo: Codable, Sendable {

    public let name: String
    public let version: String
    public let link: String

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

    static var current: Self {
        .v1_0_0_beta_3
    }
}

// list versions here
extension GeneratorInfo {

    static let v1_0_0 = GeneratorInfo(version: "1.0.0")
    static let v1_0_0_beta_4 = GeneratorInfo(version: "1.0.0-beta.4")
    static let v1_0_0_beta_3 = GeneratorInfo(version: "1.0.0-beta.3")
    static let v1_0_0_beta_2 = GeneratorInfo(version: "1.0.0-beta.2")
    static let v1_0_0_beta_1 = GeneratorInfo(version: "1.0.0-beta.1")
}
