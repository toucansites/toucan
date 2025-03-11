import ToucanModels

public extension ContentDefinition.Mocks {

    static func rss() -> ContentDefinition {
        .init(
            id: "rss",
            paths: [],
            properties: [:],
            relations: [:],
            queries: [
                // for testing purpopses, we use authors, posts and tags
                "posts": .init(
                    contentType: "post",
                    scope: "list",
                    orderBy: [
                        .init(key: "lastUpdate", direction: .desc)
                    ]
                ),
                "authors": .init(
                    contentType: "author",
                    scope: "list",
                    orderBy: [
                        .init(key: "lastUpdate", direction: .desc)
                    ]
                ),
                "tags": .init(
                    contentType: "tag",
                    scope: "list",
                    orderBy: [
                        .init(key: "lastUpdate", direction: .desc)
                    ]
                ),
            ]
        )
    }
}
