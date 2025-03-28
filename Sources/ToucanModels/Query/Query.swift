//
//  Query.swift
//  TestApp
//
//  Created by Tibor Bodecs on 2025. 01. 15..
//

public struct Query: Decodable, Equatable {

    enum CodingKeys: String, CodingKey {
        case contentType
        case scope
        case limit
        case offset
        case filter
        case orderBy
    }

    public var contentType: String
    public var scope: String?
    public var limit: Int?
    public var offset: Int?
    public var filter: Condition?
    public var orderBy: [Order]

    // MARK: - init

    public init(
        contentType: String,
        scope: String? = nil,
        limit: Int? = nil,
        offset: Int? = nil,
        filter: Condition? = nil,
        orderBy: [Order] = []
    ) {
        self.contentType = contentType
        self.scope = scope
        self.limit = limit
        self.offset = offset
        self.filter = filter
        self.orderBy = orderBy
    }

    // MARK: - decoder

    public init(
        from decoder: any Decoder
    ) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let contentType = try container.decode(
            String.self,
            forKey: .contentType
        )

        let scope = try container.decodeIfPresent(
            String.self,
            forKey: .scope
        )

        let limit = try container.decodeIfPresent(
            Int.self,
            forKey: .limit
        )

        let offset = try container.decodeIfPresent(
            Int.self,
            forKey: .offset
        )

        let filter = try container.decodeIfPresent(
            Condition.self,
            forKey: .filter
        )

        let orderBy =
            try container.decodeIfPresent(
                [Order].self,
                forKey: .orderBy
            ) ?? []

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

extension Query {

    public func resolveFilterParameters(
        with parameters: [String: AnyCodable]
    ) -> Self {
        .init(
            contentType: contentType,
            scope: scope,
            limit: limit,
            offset: offset,
            filter: filter?.resolve(with: parameters),
            orderBy: orderBy
        )
    }
}
