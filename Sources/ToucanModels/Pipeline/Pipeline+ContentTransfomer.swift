//
//  Pipeline+ContentTransformer.swift
//  Toucan
//
//  Created by Tibor Bodecs on 2025. 02. 21..
//

public struct ContentTransformer: Codable {
    public var path: String
    public var name: String

    public init(
        path: String = "/usr/local/bin",
        name: String
    ) {
        self.path = path
        self.name = name
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.path =
            (try? container.decode(String.self, forKey: .path))
            ?? "/usr/local/bin"
        self.name = try container.decode(String.self, forKey: .name)
    }
}
