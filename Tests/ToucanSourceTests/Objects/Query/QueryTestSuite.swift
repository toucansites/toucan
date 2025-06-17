//
//  QueryTestSuite.swift
//  Toucan
//
//  Created by Binary Birds on 2025. 04. 15..

import Foundation
import Testing
import ToucanSerialization

@testable import ToucanSource

@Suite
struct QueryTestSuite {
    @Test
    func basics() throws {
        let object = Query(
            contentType: "post",
            scope: "custom",
            limit: 10,
            offset: 5,
            filter: .field(key: "title", operator: .like, value: "foo"),
            orderBy: [
                .init(key: "publication", direction: .desc),
                .init(key: "title"),
            ]
        )

        let encoder = ToucanYAMLEncoder()
        let decoder = ToucanYAMLDecoder()

        let value1: String = try encoder.encode(object)
        let result1 = try decoder.decode(Query.self, from: value1)

        let value2: Data = try encoder.encode(object)
        let result2 = try decoder.decode(Query.self, from: value2)

        #expect(object == result1)
        #expect(object == result2)
    }

    @Test
    func defaults() throws {
        let data = """
        contentType: post
        """

        let decoder = ToucanYAMLDecoder()

        let result = try decoder.decode(Query.self, from: data)

        #expect(result.contentType == "post")
        #expect(result.scope == nil)
        #expect(result.limit == nil)
        #expect(result.offset == nil)
        #expect(result.filter == nil)
        #expect(result.orderBy.isEmpty)
    }

    @Test
    func custom() throws {
        let data = """
        contentType: post
        scope: list
        limit: 1
        offset: 0
        filter:
            key: name
            operator: equals
            value: hello
        orderBy:
            - key: name
            - key: other
              direction: desc
        """

        let decoder = ToucanYAMLDecoder()

        let result = try decoder.decode(
            Query.self,
            from: data
        )

        #expect(result.contentType == "post")
        #expect(result.scope == "list")
        #expect(result.limit == 1)
        #expect(result.offset == 0)

        guard case let .field(key, op, value) = result.filter else {
            Issue.record("Result is not a field case.")
            return
        }

        #expect(key == "name")
        #expect(op == .equals)
        #expect(value.value(as: String.self) == "hello")

        try #require(result.orderBy.count == 2)
        #expect(result.orderBy[0].key == "name")
        #expect(result.orderBy[0].direction == .asc)
        #expect(result.orderBy[1].key == "other")
        #expect(result.orderBy[1].direction == .desc)
    }
}
