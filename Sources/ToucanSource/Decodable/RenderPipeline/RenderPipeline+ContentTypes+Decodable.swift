//
//  File.swift
//  toucan
//
//  Created by Tibor Bodecs on 2025. 02. 01..
//

import Foundation
import ToucanModels

extension RenderPipeline.ContentTypes: Decodable {

    enum CodingKeys: CodingKey {
        case include
        case exclude
        case lastUpdate
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let include =
            try container.decodeIfPresent(
                [String].self,
                forKey: .include
            ) ?? []

        let exclude =
            try container.decodeIfPresent(
                [String].self,
                forKey: .exclude
            ) ?? []

        let lastUpdate =
            try container.decodeIfPresent(
                [String].self,
                forKey: .lastUpdate
            ) ?? []

        self.init(
            include: include,
            exclude: exclude,
            lastUpdate: lastUpdate
        )
    }

}
