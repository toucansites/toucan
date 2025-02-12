//
//  File.swift
//  toucan
//
//  Created by Tibor Bodecs on 2025. 02. 01..
//

import Foundation
import ToucanModels
import ToucanCodable

extension RenderPipeline.Engine: Decodable {

    enum CodingKeys: CodingKey {
        case id
        case options
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let id = try container.decode(String.self, forKey: .id)

        let options =
            try container.decodeIfPresent(
                [String: AnyCodable].self,
                forKey: .options
            ) ?? [:]

        self.init(
            id: id,
            options: options
        )
    }
}
