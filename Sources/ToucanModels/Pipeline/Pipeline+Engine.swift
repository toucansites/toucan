//
//  Pipeline+Engine.swift
//  Toucan
//
//  Created by Tibor Bodecs on 2025. 02. 03..
//

extension Pipeline {

    public struct Engine: Decodable {

        enum CodingKeys: CodingKey {
            case id
            case options
        }

        public var id: String
        public var options: [String: AnyCodable]

        // MARK: - init

        public init(
            id: String,
            options: [String: AnyCodable]
        ) {
            self.id = id
            self.options = options
        }

        // MARK: - decoder

        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            let id = try container.decode(String.self, forKey: .id)

            let options =
                try container.decodeIfPresent(
                    [String: AnyCodable].self,
                    forKey: .options
                ) ?? [:]

            self.init(id: id, options: options)
        }
    }
}
