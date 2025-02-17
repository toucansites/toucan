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
        case filter
        case lastUpdate
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let filter =
            try container.decodeIfPresent(
                [String].self,
                forKey: .filter
            ) ?? []

        let lastUpdate =
            try container.decodeIfPresent(
                [String].self,
                forKey: .lastUpdate
            ) ?? []

        self.init(
            filter: filter,
            lastUpdate: lastUpdate
        )
    }

}
