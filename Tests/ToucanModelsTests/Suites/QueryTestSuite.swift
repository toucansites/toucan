import Testing
@testable import ToucanModels

@Suite
struct QueryTestSuite {

    @Test
    func limitOffsetOne() async throws {
        let siteBundle = SiteBundle.Mocks.complete()

        let query = Query(
            contentType: "author",
            limit: 1,
            offset: 1
        )

        let results = siteBundle.run(query: query)
        try #require(results.count == 1)
        #expect(results[0].properties["name"] == .string("Author #2"))
    }

    @Test
    func limitOffsetTwo() async throws {
        let siteBundle = SiteBundle.Mocks.complete()

        let query = Query(
            contentType: "author",
            limit: 2,
            offset: 3
        )

        let results = siteBundle.run(query: query)
        try #require(results.count == 2)
        #expect(results[0].properties["name"] == .string("Author #4"))
    }

    @Test
    func equalsFilter() async throws {
        let siteBundle = SiteBundle.Mocks.complete()

        let query = Query(
            contentType: "author",
            filter: .field(
                key: "name",
                operator: .equals,
                value: "Author #6"
            )
        )

        let results = siteBundle.run(query: query)
        try #require(results.count == 1)
        #expect(results[0].properties["name"] == .string("Author #6"))
    }

    @Test
    func notEqualsFilter() async throws {
        let siteBundle = SiteBundle.Mocks.complete()

        let query = Query(
            contentType: "author",
            filter: .field(
                key: "name",
                operator: .notEquals,
                value: "Author #1"
            )
        )

        let results = siteBundle.run(query: query)
        try #require(results.count == 9)
        #expect(results[0].properties["name"] == .string("Author #2"))
    }

    @Test
    func lessThanFilter() async throws {
        let siteBundle = SiteBundle.Mocks.complete()

        let query = Query(
            contentType: "category",
            filter: .field(
                key: "order",
                operator: .lessThan,
                value: 3
            )
        )

        let results = siteBundle.run(query: query)
        try #require(results.count == 2)
        #expect(results[0].properties["name"] == .string("Category #1"))
        #expect(results[1].properties["name"] == .string("Category #2"))
    }

    @Test
    func lessThanOrEqualsFilter() async throws {
        let siteBundle = SiteBundle.Mocks.complete()

        let query = Query(
            contentType: "category",
            filter: .field(
                key: "order",
                operator: .lessThanOrEquals,
                value: 3
            )
        )

        let results = siteBundle.run(query: query)
        try #require(results.count == 3)
        #expect(results[0].properties["name"] == .string("Category #1"))
        #expect(results[1].properties["name"] == .string("Category #2"))
        #expect(results[2].properties["name"] == .string("Category #3"))
    }

    @Test
    func greaterThanFilter() async throws {
        let siteBundle = SiteBundle.Mocks.complete()

        let query = Query(
            contentType: "category",
            filter: .field(
                key: "order",
                operator: .greaterThan,
                value: 8
            )
        )

        let results = siteBundle.run(query: query)
        try #require(results.count == 2)
        #expect(results[0].properties["name"] == .string("Category #9"))
        #expect(results[1].properties["name"] == .string("Category #10"))
    }

    @Test
    func greaterThanOrEqualsFilter() async throws {
        let siteBundle = SiteBundle.Mocks.complete()

        let query = Query(
            contentType: "category",
            filter: .field(
                key: "order",
                operator: .greaterThanOrEquals,
                value: 8
            )
        )

        let results = siteBundle.run(query: query)
        try #require(results.count == 3)
        #expect(results[0].properties["name"] == .string("Category #8"))
        #expect(results[1].properties["name"] == .string("Category #9"))
        #expect(results[2].properties["name"] == .string("Category #10"))
    }

    @Test
    func equalsFilterWithOrConditionAndOrderByDesc() async throws {
        let siteBundle = SiteBundle.Mocks.complete()

        let query = Query(
            contentType: "author",
            filter: .or([
                .field(
                    key: "name",
                    operator: .equals,
                    value: "Author #6"
                ),
                .field(
                    key: "name",
                    operator: .equals,
                    value: "Author #4"
                ),
            ]),
            orderBy: [
                .init(key: "name", direction: .desc)
            ]
        )

        let results = siteBundle.run(query: query)
        try #require(results.count == 2)
        #expect(results[0].properties["name"] == .string("Author #6"))
        #expect(results[1].properties["name"] == .string("Author #4"))
    }

    @Test
    func equalsFilterWithAndConditionEmptyresults() async throws {
        let siteBundle = SiteBundle.Mocks.complete()

        let query = Query(
            contentType: "author",
            filter: .and([
                .field(
                    key: "name",
                    operator: .equals,
                    value: "Author 6"
                ),
                .field(
                    key: "name",
                    operator: .equals,
                    value: "Author 4"
                ),
            ]),
            orderBy: [
                .init(key: "name", direction: .desc)
            ]
        )

        let results = siteBundle.run(query: query)
        #expect(results.isEmpty)
    }

    @Test
    func equalsFilterWithAndConditionMultipleProperties() async throws {
        let siteBundle = SiteBundle.Mocks.complete()

        let query = Query(
            contentType: "author",
            filter: .and([
                .field(
                    key: "name",
                    operator: .equals,
                    value: "Author #6"
                ),
                .field(
                    key: "description",
                    operator: .like,
                    value: "Author #6 desc"
                ),
            ]),
            orderBy: [
                .init(key: "name", direction: .desc)
            ]
        )

        let results = siteBundle.run(query: query)
        try #require(results.count == 1)
        #expect(results[0].properties["name"] == .string("Author #6"))
    }

    @Test
    func equalsFilterWithIn() async throws {
        let siteBundle = SiteBundle.Mocks.complete()

        let query = Query(
            contentType: "author",
            filter: .field(
                key: "name",
                operator: .in,
                value: ["Author #6", "Author #4"]
            ),
            orderBy: [
                .init(key: "name")
            ]
        )

        let results = siteBundle.run(query: query)
        try #require(results.count == 2)
        #expect(results[0].properties["name"] == .string("Author #4"))
        #expect(results[1].properties["name"] == .string("Author #6"))
    }

    @Test
    func likeFilter() async throws {
        let siteBundle = SiteBundle.Mocks.complete()

        let query = Query(
            contentType: "author",
            filter: .field(
                key: "name",
                operator: .like,
                value: "Author #1"
            )
        )

        let results = siteBundle.run(query: query)
        try #require(results.count == 2)
        #expect(results[0].properties["name"] == .string("Author #1"))
        #expect(results[1].properties["name"] == .string("Author #10"))
    }

    @Test
    func caseInsensitiveLikeFilter() async throws {
        let siteBundle = SiteBundle.Mocks.complete()

        let query = Query(
            contentType: "author",
            filter: .field(
                key: "name",
                operator: .caseInsensitiveLike,
                value: "author #1"
            )
        )

        let results = siteBundle.run(query: query)
        try #require(results.count == 2)
        #expect(results[0].properties["name"] == .string("Author #1"))
        #expect(results[1].properties["name"] == .string("Author #10"))
    }

    @Test
    func contains() async throws {
        let siteBundle = SiteBundle.Mocks.complete()

        let query = Query(
            contentType: "post",
            filter: .field(
                key: "authors",
                operator: .contains,
                value: "author-1"
            )
        )

        let results = siteBundle.run(query: query)
        try #require(results.count == 1)
        #expect(results[0].properties["name"] == .string("Post #1"))
    }
}
