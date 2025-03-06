import Foundation
import Testing
import ToucanModels
@testable import ToucanSource

@Suite
struct QueryTestSuite {

    @Test
    func limitOffsetOne() async throws {
        let sourceBundle = SourceBundle.Mocks.complete()

        let query = Query(
            contentType: "author",
            limit: 1,
            offset: 1
        )

        let results = sourceBundle.run(query: query)
        try #require(results.count == 1)
        #expect(
            results[0].properties["name"]?.value(as: String.self) == "Author #2"
        )
    }

    @Test
    func limitOffsetTwo() async throws {
        let sourceBundle = SourceBundle.Mocks.complete()

        let query = Query(
            contentType: "author",
            limit: 2,
            offset: 3
        )

        let results = sourceBundle.run(query: query)
        try #require(results.count == 2)
        #expect(
            results[0].properties["name"]?.value(as: String.self) == "Author #4"
        )
    }

    @Test
    func equalsFilter() async throws {
        let sourceBundle = SourceBundle.Mocks.complete()

        let query = Query(
            contentType: "author",
            filter: .field(
                key: "name",
                operator: .equals,
                value: .init("Author #6")
            )
        )

        let results = sourceBundle.run(query: query)
        try #require(results.count == 1)
        #expect(
            results[0].properties["name"]?.value(as: String.self) == "Author #6"
        )
    }

    @Test
    func notEqualsFilter() async throws {
        let sourceBundle = SourceBundle.Mocks.complete()

        let query = Query(
            contentType: "author",
            filter: .field(
                key: "name",
                operator: .notEquals,
                value: .init("Author #1")
            )
        )

        let results = sourceBundle.run(query: query)
        try #require(results.count == 9)
        #expect(
            results[0].properties["name"]?.value(as: String.self) == "Author #2"
        )
    }

    @Test
    func lessThanFilter() async throws {
        let sourceBundle = SourceBundle.Mocks.complete()

        let query = Query(
            contentType: "category",
            filter: .field(
                key: "order",
                operator: .lessThan,
                value: .init(3)
            )
        )

        let results = sourceBundle.run(query: query)
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
    func lessThanOrEqualsFilter() async throws {
        let sourceBundle = SourceBundle.Mocks.complete()

        let query = Query(
            contentType: "category",
            filter: .field(
                key: "order",
                operator: .lessThanOrEquals,
                value: .init(3)
            )
        )

        let results = sourceBundle.run(query: query)
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
    func greaterThanFilter() async throws {
        let sourceBundle = SourceBundle.Mocks.complete()

        let query = Query(
            contentType: "category",
            filter: .field(
                key: "order",
                operator: .greaterThan,
                value: .init(8)
            )
        )

        let results = sourceBundle.run(query: query)
        try #require(results.count == 2)
        #expect(
            results[0].properties["title"]?.value(as: String.self)
                == "Category #9"
        )
        #expect(
            results[1].properties["title"]?.value(as: String.self)
                == "Category #10"
        )
    }

    @Test
    func greaterThanOrEqualsFilter() async throws {
        let sourceBundle = SourceBundle.Mocks.complete()

        let query = Query(
            contentType: "category",
            filter: .field(
                key: "order",
                operator: .greaterThanOrEquals,
                value: .init(8)
            )
        )

        let results = sourceBundle.run(query: query)
        try #require(results.count == 3)
        #expect(
            results[0].properties["title"]?.value(as: String.self)
                == "Category #8"
        )
        #expect(
            results[1].properties["title"]?.value(as: String.self)
                == "Category #9"
        )
        #expect(
            results[2].properties["title"]?.value(as: String.self)
                == "Category #10"
        )
    }

    @Test
    func equalsFilterWithOrConditionAndOrderByDesc() async throws {
        let sourceBundle = SourceBundle.Mocks.complete()

        let query = Query(
            contentType: "author",
            filter: .or([
                .field(
                    key: "name",
                    operator: .equals,
                    value: .init("Author #6")
                ),
                .field(
                    key: "name",
                    operator: .equals,
                    value: .init("Author #4")
                ),
            ]),
            orderBy: [
                .init(key: "name", direction: .desc)
            ]
        )

        let results = sourceBundle.run(query: query)
        try #require(results.count == 2)
        #expect(
            results[0].properties["name"]?.value(as: String.self) == "Author #6"
        )
        #expect(
            results[1].properties["name"]?.value(as: String.self) == "Author #4"
        )
    }

    @Test
    func equalsFilterWithAndConditionEmptyresults() async throws {
        let sourceBundle = SourceBundle.Mocks.complete()

        let query = Query(
            contentType: "author",
            filter: .and([
                .field(
                    key: "name",
                    operator: .equals,
                    value: .init("Author 6")
                ),
                .field(
                    key: "name",
                    operator: .equals,
                    value: .init("Author 4")
                ),
            ]),
            orderBy: [
                .init(key: "name", direction: .desc)
            ]
        )

        let results = sourceBundle.run(query: query)
        #expect(results.isEmpty)
    }

    @Test
    func equalsFilterWithAndConditionMultipleProperties() async throws {
        let sourceBundle = SourceBundle.Mocks.complete()

        let query = Query(
            contentType: "author",
            filter: .and([
                .field(
                    key: "name",
                    operator: .equals,
                    value: .init("Author #6")
                ),
                .field(
                    key: "description",
                    operator: .like,
                    value: .init("Author #6 desc")
                ),
            ]),
            orderBy: [
                .init(key: "name", direction: .desc)
            ]
        )

        let results = sourceBundle.run(query: query)
        try #require(results.count == 1)
        #expect(
            results[0].properties["name"]?.value(as: String.self) == "Author #6"
        )
    }

    @Test
    func equalsFilterWithIn() async throws {
        let sourceBundle = SourceBundle.Mocks.complete()

        let query = Query(
            contentType: "author",
            filter: .field(
                key: "name",
                operator: .in,
                value: .init(["Author #6", "Author #4"])
            ),
            orderBy: [
                .init(key: "name")
            ]
        )

        let results = sourceBundle.run(query: query)
        try #require(results.count == 2)
        #expect(
            results[0].properties["name"]?.value(as: String.self) == "Author #4"
        )
        #expect(
            results[1].properties["name"]?.value(as: String.self) == "Author #6"
        )
    }

    @Test
    func likeFilter() async throws {
        let sourceBundle = SourceBundle.Mocks.complete()

        let query = Query(
            contentType: "author",
            filter: .field(
                key: "name",
                operator: .like,
                value: .init("Author #1")
            )
        )

        let results = sourceBundle.run(query: query)
        try #require(results.count == 2)
        #expect(
            results[0].properties["name"]?.value(as: String.self) == "Author #1"
        )
        #expect(
            results[1].properties["name"]?.value(as: String.self)
                == "Author #10"
        )
    }

    @Test
    func caseInsensitiveLikeFilter() async throws {
        let sourceBundle = SourceBundle.Mocks.complete()

        let query = Query(
            contentType: "author",
            filter: .field(
                key: "name",
                operator: .caseInsensitiveLike,
                value: .init("author #1")
            )
        )

        let results = sourceBundle.run(query: query)
        try #require(results.count == 2)
        #expect(
            results[0].properties["name"]?.value(as: String.self) == "Author #1"
        )
        #expect(
            results[1].properties["name"]?.value(as: String.self)
                == "Author #10"
        )
    }

    @Test
    func contains() async throws {
        let sourceBundle = SourceBundle.Mocks.complete()

        let query = Query(
            contentType: "post",
            filter: .field(
                key: "authors",
                operator: .contains,
                value: .init("author-1")
            )
        )

        let results = sourceBundle.run(query: query)
        try #require(results.count == 8)
    }

    @Test
    func nextPost() async throws {
        let sourceBundle = SourceBundle.Mocks.complete()

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        let now = Date()
        let diff = Double(5) * -86_400
        let pastDate = now.addingTimeInterval(diff)
        //        let date = formatter.string(from: pastDate)

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
        let results1 = sourceBundle.run(query: query1)
        try #require(results1.count == 5)

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
                    direction: .asc
                )
            ]
        )

        let results = sourceBundle.run(query: query)
        try #require(results.count == 1)
        #expect(
            results[0].properties["title"]?.value(as: String.self) == "Post #6"
        )
    }
    
    @Test
    func nextGuide() async throws {
        let sourceBundle = SourceBundle.Mocks.complete()

        let query1 = Query(
            contentType: "guide",
            filter: .and(
                [
                    .field(
                        key: "order",
                        operator: .greaterThan,
                        value: 2
                    ),
                    .field(
                        key: "category",
                        operator: .equals,
                        value: "category-6"
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
        let results1 = sourceBundle.run(query: query1)
        try #require(results1.count == 1)
    }
}
