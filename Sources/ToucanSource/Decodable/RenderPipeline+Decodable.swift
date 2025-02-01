//
//  File.swift
//  toucan
//
//  Created by Tibor Bodecs on 2025. 01. 31..
//

import Foundation
import ToucanModels


extension RenderPipeline: Decodable {

    enum CodingKeys: CodingKey {
        case scopes
        case queries
        case contentType
        case engine
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let scopes =
            try container.decodeIfPresent(
                [String: [Scope]].self,
                forKey: .scopes
            ) ?? [:]

        let queries =
            try container.decodeIfPresent(
                [String: Query].self,
                forKey: .queries
            ) ?? [:]
        // TODO: make a choice which one should be the default: single vs all ?!?
        let contentType =
            try container.decodeIfPresent(
                ContentTypes.self,
                forKey: .contentType
            ) ?? .single
        let engine = try container.decode(Engine.self, forKey: .engine)

        self.init(
            scopes: scopes,
            queries: queries,
            contentType: contentType,
            engine: engine
        )
    }
}
