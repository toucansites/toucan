import ToucanModels
import ToucanSource
import ToucanCodable

public extension RenderPipeline.Mocks {

    static func rss() -> RenderPipeline {
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
                include: [
                    "rss"
                ],
                exclude: [],
                lastUpdate: [
                    "post",
                    "author",
                    "tag",
                ]
            ),
            iterators: [:],
            transformers: [:],
            engine: .init(
                id: "mustache",
                options: [
                    "contentTypes": [
                        "rss": [
                            "template": "rss"
                        ]
                    ]
                ]
            ),
            output: .init(
                path: "",
                file: "rss",
                ext: "xml"
            )
        )
    }
}
