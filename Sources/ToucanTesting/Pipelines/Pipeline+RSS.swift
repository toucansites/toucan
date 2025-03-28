import ToucanModels
import ToucanSource

public extension Pipeline.Mocks {

    static func rss() -> Pipeline {
        .init(
            id: "rss",
            scopes: [:],
            queries: [:],
            dataTypes: .init(
                date: .init(
                    formats: [
                        "full": .init(format: "y.m.d.")
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
