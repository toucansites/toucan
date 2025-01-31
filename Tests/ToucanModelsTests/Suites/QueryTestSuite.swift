import Testing
@testable import ToucanModels

@Suite
struct QueryTestSuite {

    @Test
    func equalsFilter() async throws {
        let siteBundle = SiteBundle.Mocks.complete()

        let query = Query(
            contentType: "author",
            filter: .field(
                key: "name",
                operator: .equals,
                value: "Author 6"
            )
        )

        let result = siteBundle.run(query: query)
        #expect(result.count == 1)
        #expect(result[0].properties["name"] == .string("Author 6"))
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

        let result = siteBundle.run(query: query)
        #expect(result.count == 2)
        #expect(result[0].properties["name"] == .string("Author 6"))
        #expect(result[1].properties["name"] == .string("Author 4"))
    }

    @Test
    func equalsFilterWithAndConditionEmptyResult() async throws {
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

        let result = siteBundle.run(query: query)
        #expect(result.isEmpty)
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
                    value: "Author 6"
                ),
                .field(
                    key: "description",
                    operator: .like,
                    value: "Author description 6"
                ),
            ]),
            orderBy: [
                .init(key: "name", direction: .desc)
            ]
        )

        let result = siteBundle.run(query: query)
        #expect(result.count == 1)
        #expect(result[0].properties["name"] == .string("Author 6"))
    }

    @Test
    func equalsFilterWithIn() async throws {
        let siteBundle = SiteBundle.Mocks.complete()

        let query = Query(
            contentType: "author",
            filter: .and([
                .field(
                    key: "name",
                    operator: .in,
                    value: ["Author 6", "Author 4"]
                )
            ]),
            orderBy: [
                .init(key: "name")
            ]
        )

        let result = siteBundle.run(query: query)
        #expect(result.count == 2)
        #expect(result[0].properties["name"] == .string("Author 4"))
        #expect(result[1].properties["name"] == .string("Author 6"))
    }
}
