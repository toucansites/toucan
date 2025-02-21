import ToucanModels
import ToucanSource
import ToucanCodable

public extension Pipeline.Mocks {

    static func sitemap() -> Pipeline {
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
                    "sitemap"
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
