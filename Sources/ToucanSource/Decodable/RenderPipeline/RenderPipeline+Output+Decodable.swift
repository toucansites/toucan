//
//  File.swift
//  toucan
//
//  Created by Tibor Bodecs on 2025. 02. 16..
//

extension RenderPipeline.Output: Decodable {

    enum CodingKeys: CodingKey {
        case path
        case file
        case ext
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let path = try container.decode(String.self, forKey: .path)
        let file = try container.decode(String.self, forKey: .file)
        let ext = try container.decode(String.self, forKey: .ext)

        self.init(
            path: path,
            file: file,
            ext: ext
        )
    }
}
