////
////  QueryTestSuite.swift
////  Toucan
////
////  Created by Binary Birds on 2025. 04. 15..
//
//import Foundation
//import Testing
//
//@testable import ToucanSDK
//
//@Suite
//struct QueryTestSuite {
//
//    @Test
//    func limitOffsetOne() async throws {
//        let sourceBundle = BuildTargetSource.Mocks.complete()
//
//        let query = Query(
//            contentType: "author",
//            limit: 1,
//            offset: 1
//        )
//
//        let now = Date().timeIntervalSince1970
//        let results = sourceBundle.contents.run(query: query, now: now)
//        try #require(results.count == 1)
//        #expect(
//            results[0].properties["name"]?.value(as: String.self) == "Author #2"
//        )
//    }
//
//    @Test
//    func limitOffsetTwo() async throws {
//        let sourceBundle = BuildTargetSource.Mocks.complete()
//
//        let query = Query(
//            contentType: "author",
//            limit: 2,
//            offset: 3
//        )
//
//        let now = Date().timeIntervalSince1970
//        let results = sourceBundle.contents.run(query: query, now: now)
//        try #require(results.count == 2)
//        #expect(
//            results[0].properties["name"]?.value(as: String.self) == "Author #4"
//        )
//    }
//
//    @Test
//    func equalsFilterString() async throws {
//        let sourceBundle = BuildTargetSource.Mocks.complete()
//
//        let query = Query(
//            contentType: "author",
//            filter: .field(
//                key: "name",
//                operator: .equals,
//                value: .init("Author #6")
//            )
//        )
//
//        let now = Date().timeIntervalSince1970
//        let results = sourceBundle.contents.run(query: query, now: now)
//        try #require(results.count == 1)
//        #expect(
//            results[0].properties["name"]?.value(as: String.self) == "Author #6"
//        )
//    }
//
//    @Test
//    func equalsFilterInt() async throws {
//        let sourceBundle = BuildTargetSource.Mocks.complete()
//
//        let query = Query(
//            contentType: "author",
//            filter: .field(
//                key: "age",
//                operator: .equals,
//                value: .init(22)
//            )
//        )
//
//        let now = Date().timeIntervalSince1970
//        let results = sourceBundle.contents.run(query: query, now: now)
//        try #require(results.count == 1)
//        #expect(
//            results[0].properties["name"]?.value(as: String.self) == "Author #2"
//        )
//    }
//
//    @Test
//    func equalsFilterDouble() async throws {
//        let sourceBundle = BuildTargetSource.Mocks.complete()
//
//        let query = Query(
//            contentType: "author",
//            filter: .field(
//                key: "height",
//                operator: .equals,
//                value: .init(183.0)
//            )
//        )
//
//        let now = Date().timeIntervalSince1970
//        let results = sourceBundle.contents.run(query: query, now: now)
//        try #require(results.count == 1)
//        #expect(
//            results[0].properties["name"]?.value(as: String.self) == "Author #3"
//        )
//    }
//
//    @Test
//    func equalsFilterNoResulr() async throws {
//        let sourceBundle = BuildTargetSource.Mocks.complete()
//
//        let query = Query(
//            contentType: "author",
//            filter: .field(
//                key: "height",
//                operator: .equals,
//                value: .init(666)
//            )
//        )
//
//        let now = Date().timeIntervalSince1970
//        let results = sourceBundle.contents.run(query: query, now: now)
//        try #require(results.count == 0)
//    }
//
//    @Test
//    func notEqualsFilter() async throws {
//        let sourceBundle = BuildTargetSource.Mocks.complete()
//
//        let query = Query(
//            contentType: "author",
//            filter: .field(
//                key: "name",
//                operator: .notEquals,
//                value: .init("Author #1")
//            )
//        )
//
//        let now = Date().timeIntervalSince1970
//        let results = sourceBundle.contents.run(query: query, now: now)
//        try #require(results.count == 9)
//        #expect(
//            results[0].properties["name"]?.value(as: String.self) == "Author #2"
//        )
//    }
//
//    @Test
//    func lessThanFilter() async throws {
//        let sourceBundle = BuildTargetSource.Mocks.complete()
//
//        let query = Query(
//            contentType: "category",
//            filter: .field(
//                key: "order",
//                operator: .lessThan,
//                value: .init(3)
//            )
//        )
//
//        let now = Date().timeIntervalSince1970
//        let results = sourceBundle.contents.run(query: query, now: now)
//        try #require(results.count == 2)
//        #expect(
//            results[0].properties["title"]?.value(as: String.self)
//                == "Category #1"
//        )
//        #expect(
//            results[1].properties["title"]?.value(as: String.self)
//                == "Category #2"
//        )
//    }
//
//    @Test
//    func lessThanOrEqualsFilterInt() async throws {
//        let sourceBundle = BuildTargetSource.Mocks.complete()
//
//        let query = Query(
//            contentType: "category",
//            filter: .field(
//                key: "order",
//                operator: .lessThanOrEquals,
//                value: .init(3)
//            )
//        )
//
//        let now = Date().timeIntervalSince1970
//        let results = sourceBundle.contents.run(query: query, now: now)
//        try #require(results.count == 3)
//        #expect(
//            results[0].properties["title"]?.value(as: String.self)
//                == "Category #1"
//        )
//        #expect(
//            results[1].properties["title"]?.value(as: String.self)
//                == "Category #2"
//        )
//        #expect(
//            results[2].properties["title"]?.value(as: String.self)
//                == "Category #3"
//        )
//    }
//
//    @Test
//    func lessThanOrEqualsFilterDouble() async throws {
//        let sourceBundle = BuildTargetSource.Mocks.complete()
//
//        let query = Query(
//            contentType: "author",
//            filter: .field(
//                key: "height",
//                operator: .lessThanOrEquals,
//                value: .init(182.0)
//            )
//        )
//
//        let now = Date().timeIntervalSince1970
//        let results = sourceBundle.contents.run(query: query, now: now)
//        try #require(results.count == 2)
//        #expect(
//            results[0].properties["name"]?.value(as: String.self)
//                == "Author #1"
//        )
//        #expect(
//            results[1].properties["name"]?.value(as: String.self)
//                == "Author #2"
//        )
//    }
//
//    @Test
//    func lessThanOrEqualsFilterString() async throws {
//        let sourceBundle = BuildTargetSource.Mocks.complete()
//
//        let query = Query(
//            contentType: "author",
//            filter: .field(
//                key: "name",
//                operator: .lessThanOrEquals,
//                value: .init("Author #2")
//            )
//        )
//
//        let now = Date().timeIntervalSince1970
//        let results = sourceBundle.contents.run(query: query, now: now)
//        try #require(results.count == 3)
//        #expect(
//            results[0].properties["name"]?.value(as: String.self)
//                == "Author #1"
//        )
//        #expect(
//            results[1].properties["name"]?.value(as: String.self)
//                == "Author #2"
//        )
//    }
//
//    @Test
//    func greaterThanFilter() async throws {
//        let sourceBundle = BuildTargetSource.Mocks.complete()
//
//        let query = Query(
//            contentType: "category",
//            filter: .field(
//                key: "order",
//                operator: .greaterThan,
//                value: .init(8)
//            )
//        )
//
//        let now = Date().timeIntervalSince1970
//        let results = sourceBundle.contents.run(query: query, now: now)
//        try #require(results.count == 2)
//        #expect(
//            results[0].properties["title"]?.value(as: String.self)
//                == "Category #9"
//        )
//        #expect(
//            results[1].properties["title"]?.value(as: String.self)
//                == "Category #10"
//        )
//    }
//
//    @Test
//    func greaterThanOrEqualsFilterInt() async throws {
//        let sourceBundle = BuildTargetSource.Mocks.complete()
//
//        let query = Query(
//            contentType: "category",
//            filter: .field(
//                key: "order",
//                operator: .greaterThanOrEquals,
//                value: .init(8)
//            )
//        )
//
//        let now = Date().timeIntervalSince1970
//        let results = sourceBundle.contents.run(query: query, now: now)
//        try #require(results.count == 3)
//        #expect(
//            results[0].properties["title"]?.value(as: String.self)
//                == "Category #8"
//        )
//        #expect(
//            results[1].properties["title"]?.value(as: String.self)
//                == "Category #9"
//        )
//        #expect(
//            results[2].properties["title"]?.value(as: String.self)
//                == "Category #10"
//        )
//    }
//
//    @Test
//    func greaterThanOrEqualsFilterDouble() async throws {
//        let sourceBundle = BuildTargetSource.Mocks.complete()
//
//        let query = Query(
//            contentType: "author",
//            filter: .field(
//                key: "height",
//                operator: .greaterThanOrEquals,
//                value: .init(189.0)
//            )
//        )
//
//        let now = Date().timeIntervalSince1970
//        let results = sourceBundle.contents.run(query: query, now: now)
//        try #require(results.count == 2)
//        #expect(
//            results[0].properties["name"]?.value(as: String.self)
//                == "Author #9"
//        )
//        #expect(
//            results[1].properties["name"]?.value(as: String.self)
//                == "Author #10"
//        )
//    }
//
//    @Test
//    func greaterThanOrEqualsFilterString() async throws {
//        let sourceBundle = BuildTargetSource.Mocks.complete()
//
//        let query = Query(
//            contentType: "author",
//            filter: .field(
//                key: "name",
//                operator: .greaterThanOrEquals,
//                value: .init("Author #7")
//            )
//        )
//
//        let now = Date().timeIntervalSince1970
//        let results = sourceBundle.contents.run(query: query, now: now)
//        try #require(results.count == 3)
//        #expect(
//            results[0].properties["name"]?.value(as: String.self)
//                == "Author #7"
//        )
//        #expect(
//            results[1].properties["name"]?.value(as: String.self)
//                == "Author #8"
//        )
//    }
//
//    @Test
//    func greaterThanNoResult() async throws {
//        let sourceBundle = BuildTargetSource.Mocks.complete()
//
//        let query = Query(
//            contentType: "author",
//            filter: .field(
//                key: "age",
//                operator: .greaterThanOrEquals,
//                value: .init("value")
//            )
//        )
//
//        let now = Date().timeIntervalSince1970
//        let results = sourceBundle.contents.run(query: query, now: now)
//        #expect(results.count == 0)
//    }
//
//    @Test
//    func equalsFilterWithOrConditionAndOrderByDesc() async throws {
//        let sourceBundle = BuildTargetSource.Mocks.complete()
//
//        let query = Query(
//            contentType: "author",
//            filter: .or([
//                .field(
//                    key: "name",
//                    operator: .equals,
//                    value: .init("Author #6")
//                ),
//                .field(
//                    key: "name",
//                    operator: .equals,
//                    value: .init("Author #4")
//                ),
//            ]),
//            orderBy: [
//                .init(key: "name", direction: .desc)
//            ]
//        )
//
//        let now = Date().timeIntervalSince1970
//        let results = sourceBundle.contents.run(query: query, now: now)
//        try #require(results.count == 2)
//        #expect(
//            results[0].properties["name"]?.value(as: String.self) == "Author #6"
//        )
//        #expect(
//            results[1].properties["name"]?.value(as: String.self) == "Author #4"
//        )
//    }
//
//    @Test
//    func equalsFilterWithAndConditionEmptyresults() async throws {
//        let sourceBundle = BuildTargetSource.Mocks.complete()
//
//        let query = Query(
//            contentType: "author",
//            filter: .and([
//                .field(
//                    key: "name",
//                    operator: .equals,
//                    value: .init("Author 6")
//                ),
//                .field(
//                    key: "name",
//                    operator: .equals,
//                    value: .init("Author 4")
//                ),
//            ]),
//            orderBy: [
//                .init(key: "name", direction: .desc)
//            ]
//        )
//
//        let now = Date().timeIntervalSince1970
//        let results = sourceBundle.contents.run(query: query, now: now)
//        #expect(results.isEmpty)
//    }
//
//    @Test
//    func equalsFilterWithAndConditionMultipleProperties() async throws {
//        let sourceBundle = BuildTargetSource.Mocks.complete()
//
//        let query = Query(
//            contentType: "author",
//            filter: .and([
//                .field(
//                    key: "name",
//                    operator: .equals,
//                    value: .init("Author #6")
//                ),
//                .field(
//                    key: "description",
//                    operator: .like,
//                    value: .init("Author #6 desc")
//                ),
//            ]),
//            orderBy: [
//                .init(key: "name", direction: .desc)
//            ]
//        )
//
//        let now = Date().timeIntervalSince1970
//        let results = sourceBundle.contents.run(query: query, now: now)
//        try #require(results.count == 1)
//        #expect(
//            results[0].properties["name"]?.value(as: String.self) == "Author #6"
//        )
//    }
//
//    @Test
//    func equalsFilterWithInStringValue() async throws {
//        let sourceBundle = BuildTargetSource.Mocks.complete()
//
//        let query = Query(
//            contentType: "author",
//            filter: .field(
//                key: "name",
//                operator: .in,
//                value: .init(["Author #6", "Author #4"])
//            ),
//            orderBy: [
//                .init(key: "name")
//            ]
//        )
//
//        let now = Date().timeIntervalSince1970
//        let results = sourceBundle.contents.run(query: query, now: now)
//        try #require(results.count == 2)
//        #expect(
//            results[0].properties["name"]?.value(as: String.self) == "Author #4"
//        )
//        #expect(
//            results[1].properties["name"]?.value(as: String.self) == "Author #6"
//        )
//    }
//
//    @Test
//    func equalsFilterWithInIntValue() async throws {
//        let sourceBundle = BuildTargetSource.Mocks.complete()
//
//        let query = Query(
//            contentType: "author",
//            filter: .field(
//                key: "age",
//                operator: .in,
//                value: .init([21, 22])
//            ),
//            orderBy: [
//                .init(key: "name")
//            ]
//        )
//
//        let now = Date().timeIntervalSince1970
//        let results = sourceBundle.contents.run(query: query, now: now)
//        try #require(results.count == 2)
//        #expect(
//            results[0].properties["name"]?.value(as: String.self) == "Author #1"
//        )
//        #expect(
//            results[1].properties["name"]?.value(as: String.self) == "Author #2"
//        )
//    }
//
//    @Test
//    func equalsFilterWithIndoubleValue() async throws {
//        let sourceBundle = BuildTargetSource.Mocks.complete()
//
//        let query = Query(
//            contentType: "author",
//            filter: .field(
//                key: "height",
//                operator: .in,
//                value: .init([181.0, 182.0])
//            ),
//            orderBy: [
//                .init(key: "name")
//            ]
//        )
//
//        let now = Date().timeIntervalSince1970
//        let results = sourceBundle.contents.run(query: query, now: now)
//        try #require(results.count == 2)
//        #expect(
//            results[0].properties["name"]?.value(as: String.self) == "Author #1"
//        )
//        #expect(
//            results[1].properties["name"]?.value(as: String.self) == "Author #2"
//        )
//    }
//
//    @Test
//    func likeFilter() async throws {
//        let sourceBundle = BuildTargetSource.Mocks.complete()
//
//        let query = Query(
//            contentType: "author",
//            filter: .field(
//                key: "name",
//                operator: .like,
//                value: .init("Author #1")
//            )
//        )
//
//        let now = Date().timeIntervalSince1970
//        let results = sourceBundle.contents.run(query: query, now: now)
//        try #require(results.count == 2)
//        #expect(
//            results[0].properties["name"]?.value(as: String.self) == "Author #1"
//        )
//        #expect(
//            results[1].properties["name"]?.value(as: String.self)
//                == "Author #10"
//        )
//    }
//
//    @Test
//    func likeFilterWrongValue() async throws {
//        let sourceBundle = BuildTargetSource.Mocks.complete()
//
//        let query = Query(
//            contentType: "author",
//            filter: .field(
//                key: "name",
//                operator: .like,
//                value: .init(100)
//            )
//        )
//
//        let now = Date().timeIntervalSince1970
//        let results = sourceBundle.contents.run(query: query, now: now)
//        try #require(results.count == 0)
//    }
//
//    @Test
//    func caseInsensitiveLikeFilter() async throws {
//        let sourceBundle = BuildTargetSource.Mocks.complete()
//
//        let query = Query(
//            contentType: "author",
//            filter: .field(
//                key: "name",
//                operator: .caseInsensitiveLike,
//                value: .init("author #1")
//            )
//        )
//
//        let now = Date().timeIntervalSince1970
//        let results = sourceBundle.contents.run(query: query, now: now)
//        try #require(results.count == 2)
//        #expect(
//            results[0].properties["name"]?.value(as: String.self) == "Author #1"
//        )
//        #expect(
//            results[1].properties["name"]?.value(as: String.self)
//                == "Author #10"
//        )
//    }
//
//    @Test
//    func caseInsensitiveLikeFilterWrongValue() async throws {
//        let sourceBundle = BuildTargetSource.Mocks.complete()
//
//        let query = Query(
//            contentType: "author",
//            filter: .field(
//                key: "name",
//                operator: .caseInsensitiveLike,
//                value: .init(100)
//            )
//        )
//
//        let now = Date().timeIntervalSince1970
//        let results = sourceBundle.contents.run(query: query, now: now)
//        try #require(results.count == 0)
//    }
//
//    @Test
//    func containsStringValue() async throws {
//        let sourceBundle = BuildTargetSource.Mocks.complete()
//
//        let query = Query(
//            contentType: "post",
//            filter: .field(
//                key: "authors",
//                operator: .contains,
//                value: .init("author-1")
//            )
//        )
//
//        let now = Date().timeIntervalSince1970
//        let results = sourceBundle.contents.run(query: query, now: now)
//        try #require(results.count == 8)
//    }
//
//    @Test
//    func containsIntValue() async throws {
//        let sourceBundle = BuildTargetSource.Mocks.complete()
//
//        let query = Query(
//            contentType: "post",
//            filter: .field(
//                key: "ages",
//                operator: .contains,
//                value: .init(22)
//            )
//        )
//
//        let now = Date().timeIntervalSince1970
//        let results = sourceBundle.contents.run(query: query, now: now)
//        try #require(results.count == 10)
//    }
//
//    @Test
//    func containsDoubleValue() async throws {
//        let sourceBundle = BuildTargetSource.Mocks.complete()
//
//        let query = Query(
//            contentType: "post",
//            filter: .field(
//                key: "heights",
//                operator: .contains,
//                value: .init(182.0)
//            )
//        )
//
//        let now = Date().timeIntervalSince1970
//        let results = sourceBundle.contents.run(query: query, now: now)
//        try #require(results.count == 10)
//    }
//
//    @Test
//    func containsNoValue() async throws {
//        let sourceBundle = BuildTargetSource.Mocks.complete()
//
//        let query = Query(
//            contentType: "post",
//            filter: .field(
//                key: "heights",
//                operator: .contains,
//                value: .init(666)
//            )
//        )
//
//        let now = Date().timeIntervalSince1970
//        let results = sourceBundle.contents.run(query: query, now: now)
//        try #require(results.count == 0)
//    }
//
//    @Test
//    func matchingWithString() async throws {
//        let sourceBundle = BuildTargetSource.Mocks.complete()
//
//        let query = Query(
//            contentType: "post",
//            filter: .field(
//                key: "authors",
//                operator: .matching,
//                value: ["author-1", "author-2"]
//            )
//        )
//
//        let now = Date().timeIntervalSince1970
//        let results = sourceBundle.contents.run(query: query, now: now)
//        try #require(results.count == 8)
//    }
//
//    @Test
//    func matchingWithInt() async throws {
//        let sourceBundle = BuildTargetSource.Mocks.complete()
//
//        let query = Query(
//            contentType: "post",
//            filter: .field(
//                key: "ages",
//                operator: .matching,
//                value: [21, 22]
//            )
//        )
//
//        let now = Date().timeIntervalSince1970
//        let results = sourceBundle.contents.run(query: query, now: now)
//        try #require(results.count == 10)
//    }
//
//    @Test
//    func matchingWithDouble() async throws {
//        let sourceBundle = BuildTargetSource.Mocks.complete()
//
//        let query = Query(
//            contentType: "post",
//            filter: .field(
//                key: "heights",
//                operator: .matching,
//                value: [182.0]
//            )
//        )
//
//        let now = Date().timeIntervalSince1970
//        let results = sourceBundle.contents.run(query: query, now: now)
//        try #require(results.count == 10)
//    }
//
//    @Test
//    func matchingWithNoResult() async throws {
//        let sourceBundle = BuildTargetSource.Mocks.complete()
//
//        let query = Query(
//            contentType: "post",
//            filter: .field(
//                key: "heights",
//                operator: .matching,
//                value: [666]
//            )
//        )
//
//        let now = Date().timeIntervalSince1970
//        let results = sourceBundle.contents.run(query: query, now: now)
//        try #require(results.count == 0)
//    }
//
//    @Test
//    func nextPost() async throws {
//        let sourceBundle = BuildTargetSource.Mocks.complete()
//        let now = Date()
//        let diff = Double(5) * -86_400
//        let pastDate = now.addingTimeInterval(diff)
//
//        let query1 = Query(
//            contentType: "post",
//            filter: .field(
//                key: "publication",
//                operator: .greaterThan,
//                value: .init(pastDate.timeIntervalSince1970)
//            ),
//            orderBy: [
//                .init(
//                    key: "publication",
//                    direction: .asc
//                )
//            ]
//        )
//        let results1 = sourceBundle.contents.run(
//            query: query1,
//            now: now.timeIntervalSince1970
//        )
//        try #require(results1.count == 5)
//
//        let query = Query(
//            contentType: "post",
//            limit: 1,
//            filter: .field(
//                key: "publication",
//                operator: .greaterThan,
//                value: .init(pastDate.timeIntervalSince1970)
//            ),
//            orderBy: [
//                .init(
//                    key: "publication",
//                    direction: .asc
//                )
//            ]
//        )
//
//        let results = sourceBundle.contents.run(
//            query: query,
//            now: now.timeIntervalSince1970
//        )
//        try #require(results.count == 1)
//        #expect(
//            results[0].properties["title"]?.value(as: String.self) == "Post #6"
//        )
//    }
//
//    @Test
//    func nextGuide() async throws {
//        let sourceBundle = BuildTargetSource.Mocks.complete()
//
//        let query1 = Query(
//            contentType: "guide",
//            filter: .and(
//                [
//                    .field(
//                        key: "order",
//                        operator: .greaterThan,
//                        value: 2
//                    ),
//                    .field(
//                        key: "category",
//                        operator: .equals,
//                        value: "category-6"
//                    ),
//                ]
//            ),
//            orderBy: [
//                .init(
//                    key: "order",
//                    direction: .asc
//                )
//            ]
//        )
//        let now = Date().timeIntervalSince1970
//        let results1 = sourceBundle.contents.run(query: query1, now: now)
//        try #require(results1.count == 1)
//    }
//
//    @Test
//    func resolveFilterParametersUsingId() async throws {
//        let sourceBundle = BuildTargetSource.Mocks.complete()
//
//        let query1 = Query(
//            contentType: "guide",
//            filter: .field(
//                key: "category",
//                operator: .equals,
//                value: "{{id}}"
//            ),
//            orderBy: [
//                .init(
//                    key: "order",
//                    direction: .asc
//                )
//            ]
//        )
//        .resolveFilterParameters(
//            with: [
//                "id": "category-1"
//            ]
//        )
//        let now = Date().timeIntervalSince1970
//        let results1 = sourceBundle.contents.run(query: query1, now: now)
//        try #require(results1.count == 1)
//    }
//
//    @Test
//    func iterators() async throws {
//        let sourceBundle = BuildTargetSource.Mocks.complete()
//
//        let query = Query(
//            contentType: "page",
//            filter: .field(
//                key: "iterator",
//                operator: .equals,
//                value: true
//            )
//        )
//        let now = Date().timeIntervalSince1970
//        let resolver = ContentIteratorResolver(
//            baseUrl: "http://localhost:3000",
//            now: now
//        )
//        let contents = resolver.resolve(
//            contents: sourceBundle.contents,
//            using: Pipeline.Mocks.html()
//        )
//        let results = contents.run(query: query, now: now)
//        try #require(results.count == 5)
//    }
//
//}
