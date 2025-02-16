//
//  File.swift
//  toucan
//
//  Created by Tibor Bodecs on 2025. 02. 16..
//

extension RenderPipeline.DataTypes: Decodable {

    enum CodingKeys: CodingKey {
        case date
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let date =
            try container.decodeIfPresent(
                Date.self,
                forKey: .date
            ) ?? .init(formats: [:])

        self.init(date: date)
    }
}
