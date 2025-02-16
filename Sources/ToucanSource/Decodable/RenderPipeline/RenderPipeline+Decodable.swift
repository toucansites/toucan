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
        case dataTypes
        case contentTypes
        case iterators
        case engine
        case output
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let defaultScopes = Scope.default

        let userScopes =
            try container.decodeIfPresent(
                [String: [String: Scope]].self,
                forKey: .scopes
            ) ?? [:]

        let scopes = defaultScopes.recursivelyMerged(with: userScopes)

        let queries =
            try container.decodeIfPresent(
                [String: Query].self,
                forKey: .queries
            ) ?? [:]

        // TODO: defaults
        let dataTypes =
            try container.decodeIfPresent(
                DataTypes.self,
                forKey: .dataTypes
            ) ?? .init(date: .init(formats: [:]))

        let contentTypes =
            try container.decodeIfPresent(
                [String].self,
                forKey: .contentTypes
            ) ?? []

        let iterators =
            try container.decodeIfPresent(
                [String: Query].self,
                forKey: .iterators
            ) ?? [:]

        let engine = try container.decode(
            Engine.self,
            forKey: .engine
        )

        let output = try container.decode(
            Output.self,
            forKey: .output
        )

        self.init(
            scopes: scopes,
            queries: queries,
            dataTypes: dataTypes,
            contentTypes: contentTypes,
            iterators: iterators,
            engine: engine,
            output: output
        )
    }
}
