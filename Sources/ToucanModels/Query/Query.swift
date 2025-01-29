//
//  Query.swift
//  TestApp
//
//  Created by Tibor Bodecs on 2025. 01. 15..
//

public struct Query {

    public let contentType: String
    public let scope: String
    public let limit: Int?
    public let offset: Int?
    public let filter: Condition?
    public let orderBy: [Order]

    public init(
        contentType: String,
        scope: String,
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
