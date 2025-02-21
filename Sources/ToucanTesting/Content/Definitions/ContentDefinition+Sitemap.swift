import ToucanModels

public extension ContentDefinition.Mocks {

    static func sitemap() -> ContentDefinition {
        .init(
            type: "sitemap",
            paths: [],
            properties: [:],
            relations: [:],
            queries: [
                // for testing purpopses, we use authors, posts and tags
                "posts": .init(
                    contentType: "post",
                    scope: "list",
                    limit: 2,
                    orderBy: [
                        .init(key: "lastUpdate", direction: .desc)
                    ]
                ),
                "authors": .init(
                    contentType: "author",
                    scope: "list",
                    limit: 2,
                    orderBy: [
                        .init(key: "lastUpdate", direction: .desc)
                    ]
                ),
                "tags": .init(
                    contentType: "tag",
                    scope: "list",
                    limit: 2,
                    orderBy: [
                        .init(key: "lastUpdate", direction: .desc)
                    ]
                ),
            ]
        )
    }
}
