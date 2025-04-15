//
//  Pipeline+ContentTransformer.swift
//  Toucan
//
//  Created by Tibor Bodecs on 2025. 02. 21..
//

public struct ContentTransformer: Codable {
    public var url: String
    public var name: String

    public init(
        url: String = "/usr/local/bin",
        name: String
    ) {
        self.url = url
        self.name = name
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.url =
            (try? container.decode(String.self, forKey: .url))
            ?? "/usr/local/bin"
        self.name = try container.decode(String.self, forKey: .name)
    }
}
