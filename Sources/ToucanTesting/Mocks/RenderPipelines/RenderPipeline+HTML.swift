import ToucanModels
import ToucanSource
import ToucanCodable

public extension RenderPipeline.Mocks {

    static func html() -> RenderPipeline {
        .init(
            scopes: [:],
            queries: [:],
            dataTypes: .init(
                date: .init(
                    formats: [
                        "full": "y.m.d."
                    ]
                )
            ),
            contentTypes: .init(
                include: [],
                exclude: [
                    "rss"
                ],
                lastUpdate: []
            ),
            // are iterators are always pages? iteratorPages? or segments? 🤔
            iterators: [
                "post.pagination": .init(
                    contentType: "post",
                    limit: 2
                )
            ],
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
