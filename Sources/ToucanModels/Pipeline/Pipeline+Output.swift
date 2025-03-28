//
//  File.swift
//  toucan
//
//  Created by Tibor Bodecs on 2025. 02. 16..
//

extension Pipeline {

    public struct Output: Decodable {

        enum CodingKeys: CodingKey {
            case path
            case file
            case ext
        }

        public var path: String
        public var file: String
        public var ext: String

        // MARK: - init

        public init(
            path: String,
            file: String,
            ext: String
        ) {
            self.path = path
            self.file = file
            self.ext = ext
        }

        // MARK: - decoder

        public init(
            from decoder: any Decoder
        ) throws {
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
}
