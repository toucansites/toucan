//
//  File.swift
//  toucan
//
//  Created by Tibor Bodecs on 2025. 02. 21..
//

public struct ContentTransformer: Codable {
    public var name: String
    public var arguments: [String: String]

    public init(
        name: String,
        arguments: [String: String] = [:]
    ) {
        self.name = name
        self.arguments = arguments
    }
}
