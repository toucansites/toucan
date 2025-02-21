import ToucanModels
import ToucanSource
import ToucanCodable

public extension Pipeline.Mocks {

    static func sitemap() -> Pipeline {
        .init(
            scopes: [:],
            queries: [:],
            dataTypes: .init(),
            contentTypes: .init(
                include: [
                    "sitemap"
                ],
                exclude: [],
                lastUpdate: [
                    "tag",
                    "author",
                    "post",
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
