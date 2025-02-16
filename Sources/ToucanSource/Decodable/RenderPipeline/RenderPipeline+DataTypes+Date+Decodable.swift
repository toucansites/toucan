//
//  File.swift
//  toucan
//
//  Created by Tibor Bodecs on 2025. 02. 16..
//

extension RenderPipeline.DataTypes.Date: Decodable {

    enum CodingKeys: CodingKey {
        case formats
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let formats =
            try container.decodeIfPresent(
                [String: String].self,
                forKey: .formats
            ) ?? [:]

        self.init(formats: formats)
    }
}
