//
//  File.swift
//  toucan
//
//  Created by Viasz-Kádi Ferenc on 2025. 03. 19..
//

import Foundation

public struct Generator: Codable, Sendable {
    let name: String
    let version: String
    let link: String

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

public extension Generator {

    static let v1_0_0_beta3 = Generator(version: "1.0.0-beta3")
}
