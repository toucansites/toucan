//
//  Query.swift
//  TestApp
//
//  Created by Tibor Bodecs on 2025. 01. 15..
//

public struct Query {

    public var contentType: String
    public var scope: String?
    public var limit: Int?
    public var offset: Int?
    public var filter: Condition?
    public var orderBy: [Order]

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

    public func resolveFilterParameters(
        with parameters: [String: Any]
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

/*

 always store dates as time interval from 1970

 special field values:
 global:
    {{$now}} -> current date

 model queries:
    {{id}} -> identifier of the current item
    {{property}} -> any base property of self?
        (maybe relations, like author ids?)


     @Asdf(
        param: "...?",
     ) {

     }

     @
 */
