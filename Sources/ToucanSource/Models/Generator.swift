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
}

public extension Generator {
    
    static let v1_0_0_beta3 = Generator(name: "Toucan", version: "1.0.0-beta3")
}
