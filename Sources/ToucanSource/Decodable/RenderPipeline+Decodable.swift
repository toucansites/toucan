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

        let defaultScopes = Scope.default

        let scopes =
            try container.decodeIfPresent(
                [String: [String: Scope]].self,
                forKey: .scopes
            ) ?? [:]

        let finalScopes = defaultScopes.recursivelyMerged(with: scopes)
        print(finalScopes)

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
            scopes: finalScopes,
            queries: queries,
            contentType: contentType,
            engine: engine
        )
    }
}
