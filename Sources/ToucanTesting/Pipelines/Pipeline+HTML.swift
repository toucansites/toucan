import ToucanModels
import ToucanSource

public extension Pipeline.Mocks {

    static func html() -> Pipeline {
        .init(
            id: "html",
            scopes: [:],
            queries: [
                "featured": .init(
                    contentType: "post",
                    scope: "list",
                    filter: .field(
                        key: "featured",
                        operator: .equals,
                        value: true
                    )
                )
            ],
            dataTypes: .init(
                date: .init(
                    dateFormats: [
                        "full": .init(format: "y.m.d.")
                    ]
                )
            ),
            contentTypes: .init(
                include: [],
                exclude: [
                    "rss",
                    "sitemap",
                ],
                lastUpdate: []
            ),
            // are iterators always pages? iteratorPages? or segments? 🤔
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
                        "post": [
                            "template": "post.default"
                        ]
                    ]
                ]
            ),
            output: .init(
                path: "{{slug}}",
                file: "index",
                ext: "html"
            )
        )
    }
}
