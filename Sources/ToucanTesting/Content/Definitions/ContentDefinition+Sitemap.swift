import ToucanModels

public extension ContentDefinition.Mocks {

    static func sitemap() -> ContentDefinition {
        .init(
            id: "sitemap",
            paths: [],
            properties: [:],
            relations: [:],
            queries: [
                // for testing purpopses, we use pages, authors, posts and tags
                
                "pages": .init(
                    contentType: "page",
                    scope: "list",
                    orderBy: [
                        .init(key: "lastUpdate", direction: .desc)
                    ]
                ),
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
