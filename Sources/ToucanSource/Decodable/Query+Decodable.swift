//
//  File.swift
//  toucan
//
//  Created by Tibor Bodecs on 2025. 01. 31..
//

import ToucanModels

extension Query: Decodable {

    enum CodingKeys: String, CodingKey {
        case contentType
        case scope
        case limit
        case offset
        case filter
        case orderBy
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let contentType = try container.decode(
            String.self,
            forKey: .contentType
        )
        let scope = try container.decodeIfPresent(String.self, forKey: .scope)
        let limit = try container.decodeIfPresent(Int.self, forKey: .limit)
        let offset = try container.decodeIfPresent(Int.self, forKey: .offset)
        let filter = try container.decodeIfPresent(
            Condition.self,
            forKey: .filter
        )
        // TODO: consider turning order by to an optional?
        let orderBy =
            try container.decodeIfPresent([Order].self, forKey: .orderBy) ?? []

        self.init(
            contentType: contentType,
            scope: scope,
            limit: limit,
            offset: offset,
            filter: filter,
            orderBy: orderBy
        )
    }
}
