import ToucanModels
import ToucanSource

public extension Pipeline.Mocks {

    static func sitemap() -> Pipeline {
        .init(
            id: "sitemap",
            scopes: [:],
            queries: [
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
            ],
            dataTypes: .defaults,
            contentTypes: .init(
                include: [
                    "sitemap"
                ],
                exclude: [],
                lastUpdate: []
            ),
            iterators: [
                "post.pagination": .init(
                    contentType: "post",
                    limit: 2
                )
            ],
            transformers: [:],
            engine: .init(
                id: "mustache",
                options: [
                    "contentTypes": [
                        "sitemap": [
                            "template": "sitemap"
                        ]
                    ]
                ]
            ),
            output: .init(
                path: "",
                file: "sitemap",
                ext: "xml"
            )
        )
    }
}
