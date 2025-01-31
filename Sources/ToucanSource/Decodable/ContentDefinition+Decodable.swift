//
//  File.swift
//  toucan
//
//  Created by Tibor Bodecs on 2025. 01. 31..
//

import ToucanModels

extension ContentDefinition: Decodable {

    enum CodingKeys: CodingKey {
        case `type`
        case paths
        case properties
        case relations
        case queries
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let type = try container.decode(String.self, forKey: .type)
        let paths =
            try container.decodeIfPresent([String].self, forKey: .paths) ?? []
        let properties =
            try container.decodeIfPresent(
                [String: Property].self,
                forKey: .properties
            ) ?? [:]
        let relations =
            try container.decodeIfPresent(
                [String: Relation].self,
                forKey: .relations
            ) ?? [:]
        let queries =
            try container.decodeIfPresent(
                [String: Query].self,
                forKey: .queries
            ) ?? [:]

        self.init(
            type: type,
            paths: paths,
            properties: properties,
            relations: relations,
            queries: queries
        )
    }
}
