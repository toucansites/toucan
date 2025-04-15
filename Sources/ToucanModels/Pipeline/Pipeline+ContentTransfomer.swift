//
//  Pipeline+ContentTransformer.swift
//  Toucan
//
//  Created by Tibor Bodecs on 2025. 02. 21..
//

public struct ContentTransformer: Codable {
    public var url: String
    public var name: String
    public var arguments: [String: String]

    public init(
        url: String = "/usr/local/bin",
        name: String,
        arguments: [String: String] = [:]
    ) {
        self.url = url
        self.name = name
        self.arguments = arguments
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.url =
            (try? container.decode(String.self, forKey: .url))
            ?? "/usr/local/bin"
        self.name = try container.decode(String.self, forKey: .name)
        self.arguments = try container.decode(
            [String: String].self,
            forKey: .arguments
        )
    }
}
