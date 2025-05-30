//
//  ContentQueryTestSuite.swift
//  Toucan
//
//  Created by Binary Birds on 2025. 04. 15..
//
import Foundation
import Testing
import ToucanCore
import ToucanSerialization
import ToucanSource
@testable import ToucanSDK

@Suite
struct ContentQueryTestSuite {

    func getMockContents(now: Date) throws -> [Content] {
        let buildTargetSource = Mocks.buildTargetSource(now: now)
        let encoder = ToucanYAMLEncoder()
        let decoder = ToucanYAMLDecoder()

        let converter = ContentResolver(
            contentTypeResolver: .init(
                types: buildTargetSource.contentDefinitions,
                pipelines: buildTargetSource.pipelines
            ),
            encoder: encoder,
            decoder: decoder,
            dateFormatter: .init(
                dateConfig: buildTargetSource.config.dataTypes.date
            )
        )
        return try converter.convert(
            rawContents: buildTargetSource.rawContents
        )
    }

    @Test
    func limitOffsetOne() async throws {
        let now = Date()
        let contents = try getMockContents(now: now)

        let query = Query(
            contentType: "author",
            limit: 1,
            offset: 1
        )
        let results = contents.run(
            query: query,
            now: now.timeIntervalSince1970
        )
        try #require(results.count == 1)
        #expect(
            results[0].properties["name"]?.value(as: String.self) == "Author #2"
        )
    }

    @Test
    func limitOffsetTwo() async throws {
        let now = Date()
        let contents = try getMockContents(now: now)

        let query = Query(
            contentType: "author",
            limit: 2,
            offset: 1
        )

        let results = contents.run(
            query: query,
            now: now.timeIntervalSince1970
        )
        try #require(results.count == 2)
        #expect(
            results[0].properties["name"]?.value(as: String.self) == "Author #2"
        )
        #expect(
            results[1].properties["name"]?.value(as: String.self) == "Author #3"
        )
    }

    @Test
    func equalsFilterString() async throws {
        let now = Date()
        let contents = try getMockContents(now: now)

        let query = Query(
            contentType: "author",
            filter: .field(
                key: "name",
                operator: .equals,
                value: .init("Author #3")
            )
        )

        let results = contents.run(
            query: query,
            now: now.timeIntervalSince1970
        )
        try #require(results.count == 1)
        #expect(
            results[0].properties["name"]?.value(as: String.self) == "Author #3"
        )
    }

    @Test
    func filterInt() async throws {
        let now = Date()
        let contents = try getMockContents(now: now)

        let query = Query(
            contentType: "author",
            filter: .field(
                key: "age",
                operator: .greaterThan,
                value: 22
            )
        )

        let results = contents.run(query: query, now: now.timeIntervalSince1970)
        try #require(results.count == 1)
        #expect(
            results[0].properties["name"]?.value(as: String.self) == "Author #3"
        )
    }

    @Test
    func filterDouble() async throws {
        let now = Date()
        let contents = try getMockContents(now: now)

        let query = Query(
            contentType: "author",
            filter: .field(
                key: "lastUpdate",
                operator: .lessThan,
                value: .init(now.timeIntervalSince1970 + 1)
            )
        )

        let results = contents.run(query: query, now: now.timeIntervalSince1970)
        try #require(results.count == 3)
    }

    @Test
    func equalsFilterNoResults() async throws {
        let now = Date()
        let contents = try getMockContents(now: now)

        let query = Query(
            contentType: "author",
            filter: .field(
                key: "age",
                operator: .equals,
                value: .init(666)
            )
        )

        let results = contents.run(query: query, now: now.timeIntervalSince1970)
        try #require(results.count == 0)
    }

    @Test
    func notEqualsFilter() async throws {
        let now = Date()
        let contents = try getMockContents(now: now)

        let query = Query(
            contentType: "author",
            filter: .field(
                key: "name",
                operator: .notEquals,
                value: .init("Author #1")
            )
        )

        let results = contents.run(query: query, now: now.timeIntervalSince1970)
        try #require(results.count == 2)
        #expect(
            results[0].properties["name"]?.value(as: String.self) == "Author #2"
        )
        #expect(
            results[1].properties["name"]?.value(as: String.self) == "Author #3"
        )
    }

    @Test
    func lessThanFilter() async throws {
        let now = Date()
        let contents = try getMockContents(now: now)

        let query = Query(
            contentType: "category",
            filter: .field(
                key: "order",
                operator: .lessThan,
                value: .init(3)
            )
        )

        let results = contents.run(query: query, now: now.timeIntervalSince1970)
        try #require(results.count == 2)
        #expect(
            results[0].properties["title"]?.value(as: String.self)
                == "Category #1"
        )
        #expect(
            results[1].properties["title"]?.value(as: String.self)
                == "Category #2"
        )
    }

    @Test
    func lessThanOrEqualsFilterInt() async throws {
        let now = Date()
        let contents = try getMockContents(now: now)

        let query = Query(
            contentType: "category",
            filter: .field(
                key: "order",
                operator: .lessThanOrEquals,
                value: .init(3)
            )
        )

        let results = contents.run(query: query, now: now.timeIntervalSince1970)
        try #require(results.count == 3)
        #expect(
            results[0].properties["title"]?.value(as: String.self)
                == "Category #1"
        )
        #expect(
            results[1].properties["title"]?.value(as: String.self)
                == "Category #2"
        )
        #expect(
            results[2].properties["title"]?.value(as: String.self)
                == "Category #3"
        )
    }

    @Test
    func lessThanOrEqualsFilterDouble() async throws {
        let now = Date()
        let contents = try getMockContents(now: now)

        let query = Query(
            contentType: "post",
            filter: .field(
                key: "rating",
                operator: .lessThanOrEquals,
                value: .init(1.5)
            )
        )

        let results = contents.run(query: query, now: now.timeIntervalSince1970)
        try #require(results.count == 1)
        #expect(
            results[0].properties["title"]?.value(as: String.self) == "Post #1"
        )
    }

    @Test
    func lessThanOrEqualsFilterString() async throws {
        let now = Date()
        let contents = try getMockContents(now: now)

        let query = Query(
            contentType: "author",
            filter: .field(
                key: "name",
                operator: .lessThanOrEquals,
                value: .init("Author #2")
            )
        )

        let results = contents.run(query: query, now: now.timeIntervalSince1970)
        try #require(results.count == 2)
        #expect(
            results[0].properties["name"]?.value(as: String.self)
                == "Author #1"
        )
        #expect(
            results[1].properties["name"]?.value(as: String.self)
                == "Author #2"
        )
    }

    @Test
    func greaterThanFilter() async throws {
        let now = Date()
        let contents = try getMockContents(now: now)

        let query = Query(
            contentType: "category",
            filter: .field(
                key: "order",
                operator: .greaterThan,
                value: .init(2)
            )
        )

        let results = contents.run(query: query, now: now.timeIntervalSince1970)
        try #require(results.count == 1)
        #expect(
            results[0].properties["title"]?.value(as: String.self)
                == "Category #3"
        )
    }

    @Test
    func greaterThanOrEqualsFilterInt() async throws {
        let now = Date()
        let contents = try getMockContents(now: now)

        let query = Query(
            contentType: "category",
            filter: .field(
                key: "order",
                operator: .greaterThanOrEquals,
                value: .init(2)
            )
        )

        let results = contents.run(query: query, now: now.timeIntervalSince1970)
        try #require(results.count == 2)
        #expect(
            results[0].properties["title"]?.value(as: String.self)
                == "Category #2"
        )
        #expect(
            results[1].properties["title"]?.value(as: String.self)
                == "Category #3"
        )
    }

    @Test
    func greaterThanOrEqualsFilterDouble() async throws {
        let now = Date()
        let contents = try getMockContents(now: now)

        let query = Query(
            contentType: "post",
            filter: .field(
                key: "rating",
                operator: .greaterThanOrEquals,
                value: .init(2.0)
            )
        )

        let results = contents.run(query: query, now: now.timeIntervalSince1970)
        try #require(results.count == 2)
        #expect(
            results[0].properties["title"]?.value(as: String.self)
                == "Post #2"
        )
        #expect(
            results[1].properties["title"]?.value(as: String.self)
                == "Post #3"
        )
    }

    @Test
    func greaterThanOrEqualsFilterString() async throws {
        let now = Date()
        let contents = try getMockContents(now: now)

        let query = Query(
            contentType: "author",
            filter: .field(
                key: "name",
                operator: .greaterThanOrEquals,
                value: .init("Author #3")
            )
        )

        let results = contents.run(query: query, now: now.timeIntervalSince1970)
        try #require(results.count == 1)
        #expect(
            results[0].properties["name"]?.value(as: String.self)
                == "Author #3"
        )
    }

    @Test
    func greaterThanNoResult() async throws {
        let now = Date()
        let contents = try getMockContents(now: now)

        let query = Query(
            contentType: "author",
            filter: .field(
                key: "age",
                operator: .greaterThanOrEquals,
                value: .init("value")
            )
        )

        let results = contents.run(query: query, now: now.timeIntervalSince1970)
        #expect(results.count == 0)
    }

    @Test
    func equalsFilterWithOrConditionAndOrderByDesc() async throws {
        let now = Date()
        let contents = try getMockContents(now: now)

        let query = Query(
            contentType: "author",
            filter: .or([
                .field(
                    key: "name",
                    operator: .equals,
                    value: .init("Author #1")
                ),
                .field(
                    key: "name",
                    operator: .equals,
                    value: .init("Author #3")
                ),
            ]),
            orderBy: [
                .init(key: "name", direction: .desc)
            ]
        )

        let results = contents.run(query: query, now: now.timeIntervalSince1970)
        try #require(results.count == 2)
        #expect(
            results[0].properties["name"]?.value(as: String.self) == "Author #3"
        )
        #expect(
            results[1].properties["name"]?.value(as: String.self) == "Author #1"
        )
    }

    @Test
    func equalsFilterWithAndConditionEmptyresults() async throws {
        let now = Date()
        let contents = try getMockContents(now: now)

        let query = Query(
            contentType: "author",
            filter: .and([
                .field(
                    key: "name",
                    operator: .equals,
                    value: .init("Author 1")
                ),
                .field(
                    key: "name",
                    operator: .equals,
                    value: .init("Author 3")
                ),
            ]),
            orderBy: [
                .init(key: "name", direction: .desc)
            ]
        )

        let results = contents.run(query: query, now: now.timeIntervalSince1970)
        #expect(results.isEmpty)
    }

    @Test
    func equalsFilterWithAndConditionMultipleProperties() async throws {
        let now = Date()
        let contents = try getMockContents(now: now)

        let query = Query(
            contentType: "author",
            filter: .and([
                .field(
                    key: "name",
                    operator: .equals,
                    value: .init("Author #2")
                ),
                .field(
                    key: "description",
                    operator: .like,
                    value: .init("Author #2 desc")
                ),
            ]),
            orderBy: [
                .init(key: "name", direction: .desc)
            ]
        )

        let results = contents.run(query: query, now: now.timeIntervalSince1970)
        try #require(results.count == 1)
        #expect(
            results[0].properties["name"]?.value(as: String.self) == "Author #2"
        )
    }

    @Test
    func equalsFilterWithInStringValue() async throws {
        let now = Date()
        let contents = try getMockContents(now: now)

        let query = Query(
            contentType: "author",
            filter: .field(
                key: "name",
                operator: .in,
                value: .init(["Author #2", "Author #3"])
            ),
            orderBy: [
                .init(key: "name")
            ]
        )

        let results = contents.run(query: query, now: now.timeIntervalSince1970)
        try #require(results.count == 2)
        #expect(
            results[0].properties["name"]?.value(as: String.self) == "Author #2"
        )
        #expect(
            results[1].properties["name"]?.value(as: String.self) == "Author #3"
        )
    }

    @Test
    func equalsFilterWithInIntValue() async throws {
        let now = Date()
        let contents = try getMockContents(now: now)

        let query = Query(
            contentType: "author",
            filter: .field(
                key: "age",
                operator: .in,
                value: .init([21, 42])
            ),
            orderBy: [
                .init(key: "name")
            ]
        )

        let results = contents.run(query: query, now: now.timeIntervalSince1970)
        try #require(results.count == 2)
        #expect(
            results[0].properties["name"]?.value(as: String.self) == "Author #2"
        )
        #expect(
            results[1].properties["name"]?.value(as: String.self) == "Author #3"
        )
    }

    @Test
    func equalsFilterWithIndoubleValue() async throws {
        let now = Date()
        let contents = try getMockContents(now: now)

        let query = Query(
            contentType: "post",
            filter: .field(
                key: "rating",
                operator: .in,
                value: .init([1.0, 3.0])
            ),
            orderBy: [
                .init(key: "title")
            ]
        )

        let results = contents.run(query: query, now: now.timeIntervalSince1970)
        try #require(results.count == 2)
        #expect(
            results[0].properties["title"]?.value(as: String.self) == "Post #1"
        )
        #expect(
            results[1].properties["title"]?.value(as: String.self) == "Post #3"
        )
    }

    @Test
    func likeFilter() async throws {
        let now = Date()
        let contents = try getMockContents(now: now)

        let query = Query(
            contentType: "author",
            filter: .field(
                key: "name",
                operator: .like,
                value: .init("Auth")
            )
        )

        let results = contents.run(query: query, now: now.timeIntervalSince1970)
        try #require(results.count == 3)
    }

    @Test
    func likeFilterWrongValue() async throws {
        let now = Date()
        let contents = try getMockContents(now: now)

        let query = Query(
            contentType: "author",
            filter: .field(
                key: "name",
                operator: .like,
                value: .init(100)
            )
        )

        let results = contents.run(query: query, now: now.timeIntervalSince1970)
        try #require(results.count == 0)
    }

    @Test
    func caseInsensitiveLikeFilter() async throws {
        let now = Date()
        let contents = try getMockContents(now: now)

        let query = Query(
            contentType: "author",
            filter: .field(
                key: "name",
                operator: .caseInsensitiveLike,
                value: .init("author #1")
            )
        )

        let results = contents.run(query: query, now: now.timeIntervalSince1970)
        try #require(results.count == 1)
        #expect(
            results[0].properties["name"]?.value(as: String.self) == "Author #1"
        )
    }

    @Test
    func caseInsensitiveLikeFilterWrongValue() async throws {
        let now = Date()
        let contents = try getMockContents(now: now)

        let query = Query(
            contentType: "author",
            filter: .field(
                key: "name",
                operator: .caseInsensitiveLike,
                value: .init(100)
            )
        )

        let results = contents.run(query: query, now: now.timeIntervalSince1970)
        try #require(results.count == 0)
    }

    @Test
    func containsStringValue() async throws {
        let now = Date()
        let contents = try getMockContents(now: now)

        let query = Query(
            contentType: "post",
            filter: .field(
                key: "authors",
                operator: .contains,
                value: .init("author-1")
            )
        )

        let results = contents.run(query: query, now: now.timeIntervalSince1970)
        try #require(results.count == 2)
    }

    @Test
    func equalsDoubleValue() async throws {
        let now = Date()
        let contents = try getMockContents(now: now)

        let query = Query(
            contentType: "post",
            filter: .field(
                key: "rating",
                operator: .equals,
                value: .init(1.0)
            )
        )

        let results = contents.run(query: query, now: now.timeIntervalSince1970)
        try #require(results.count == 1)
    }

    @Test
    func inDoubleValue() async throws {
        let now = Date()
        let contents = try getMockContents(now: now)

        let query = Query(
            contentType: "post",
            filter: .field(
                key: "rating",
                operator: .in,
                value: [2.0, 3.0]
            )
        )

        let results = contents.run(query: query, now: now.timeIntervalSince1970)
        try #require(results.count == 2)
    }

    @Test
    func containsNoValue() async throws {
        let now = Date()
        let contents = try getMockContents(now: now)

        let query = Query(
            contentType: "post",
            filter: .field(
                key: "rating",
                operator: .contains,
                value: .init(666)
            )
        )

        let results = contents.run(query: query, now: now.timeIntervalSince1970)
        try #require(results.count == 0)
    }

    @Test
    func matchingWithString() async throws {
        let now = Date()
        let contents = try getMockContents(now: now)

        let query = Query(
            contentType: "post",
            filter: .field(
                key: "authors",
                operator: .matching,
                value: ["author-1", "author-2"]
            )
        )

        let results = contents.run(query: query, now: now.timeIntervalSince1970)
        try #require(results.count == 3)
    }

    @Test
    func matching() async throws {
        let now = Date()
        let contents = try getMockContents(now: now)

        let query = Query(
            contentType: "post",
            filter: .field(
                key: "authors",
                operator: .matching,
                value: ["author-1"]
            )
        )

        let results = contents.run(query: query, now: now.timeIntervalSince1970)
        try #require(results.count == 2)
    }

    @Test
    func matchingWithNoResult() async throws {
        let now = Date()
        let contents = try getMockContents(now: now)

        let query = Query(
            contentType: "post",
            filter: .field(
                key: "authors",
                operator: .matching,
                value: ["author-4"]
            )
        )

        let results = contents.run(query: query, now: now.timeIntervalSince1970)
        try #require(results.count == 0)
    }

    @Test
    func nextPost() async throws {
        let now = Date()
        let contents = try getMockContents(now: now)
        let pastDate =
            now
            .addingTimeInterval(-86_400 * 2)
            // TODO: double check this
            .addingTimeInterval(-1)

        let query1 = Query(
            contentType: "post",
            filter: .field(
                key: "publication",
                operator: .greaterThan,
                value: .init(pastDate.timeIntervalSince1970)
            ),
            orderBy: [
                .init(
                    key: "publication",
                    direction: .asc
                )
            ]
        )
        let results1 = contents.run(
            query: query1,
            now: now.timeIntervalSince1970
        )

        try #require(results1.count == 2)

        #expect(
            results1[0].properties["title"]?.value(as: String.self) == "Post #2"
        )
        #expect(
            results1[1].properties["title"]?.value(as: String.self) == "Post #1"
        )

        let query = Query(
            contentType: "post",
            limit: 1,
            filter: .field(
                key: "publication",
                operator: .greaterThan,
                value: .init(pastDate.timeIntervalSince1970)
            ),
            orderBy: [
                .init(
                    key: "publication",
                    direction: .desc
                )
            ]
        )

        let results2 = contents.run(
            query: query,
            now: now.timeIntervalSince1970
        )

        try #require(results2.count == 1)

        #expect(
            results1[0].properties["title"]?.value(as: String.self) == "Post #2"
        )
    }

    @Test
    func nextGuide() async throws {
        let now = Date()
        let contents = try getMockContents(now: now)

        let query1 = Query(
            contentType: "guide",
            filter: .and(
                [
                    .field(
                        key: "order",
                        operator: .greaterThan,
                        value: 8
                    ),
                    .field(
                        key: "category",
                        operator: .equals,
                        value: "category-3"
                    ),
                ]
            ),
            orderBy: [
                .init(
                    key: "order",
                    direction: .asc
                )
            ]
        )

        let results1 = contents.run(
            query: query1,
            now: now.timeIntervalSince1970
        )
        try #require(results1.count == 1)
    }

    @Test
    func resolveFilterParametersUsingId() async throws {
        let now = Date()
        let contents = try getMockContents(now: now)

        let query1 = Query(
            contentType: "guide",
            filter: .field(
                key: "category",
                operator: .equals,
                value: "{{id}}"
            ),
            orderBy: [
                .init(
                    key: "order",
                    direction: .asc
                )
            ]
        )
        .resolveFilterParameters(
            with: [
                "id": "category-1"
            ]
        )

        let results1 = contents.run(
            query: query1,
            now: now.timeIntervalSince1970
        )
        try #require(results1.count == 3)
    }
}
