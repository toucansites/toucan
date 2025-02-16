import ToucanModels
import ToucanSource

public extension RenderPipeline.Mocks {

    static func defaults() -> [RenderPipeline] {
        return [
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
                contentTypes: .all,
                engine: .init(
                    id: "mustache",
                    options: [
                        "contentTypes": [
                            "post": [
                                // segments
                                "iterators": [
                                    "list": [
                                        "limit": 10
                                            // FULL QUERY?
                                    ]
                                ],
                                "template": "post.default.template",
                            ]
                        ]
                    ]
                ),
                output: .init(
                    path: "{{slug}}",
                    file: "index",
                    ext: "html"
                )
            ),
            .init(
                scopes: [
                    "*": [
                        "reference": .init(
                            context: .reference,
                            fields: []
                        ),
                        "list": .init(
                            context: .list,
                            fields: []
                        ),
                        "detail": .init(
                            context: .detail,
                            fields: []
                        ),
                        "custom": .init(
                            context: .properties,
                            fields: ["id"]
                        ),
                    ]
                ],
                queries: [
                    "featured": .init(
                        contentType: "post",
                        scope: "list",
                        filter: .field(
                            key: "featured",
                            operator: .equals,
                            value: .init(true)
                        )
                    )
                ],
                dataTypes: .init(
                    date: .init(
                        formats: [
                            "full": "y.m.d."
                        ]
                    )
                ),
                contentTypes: .all,
                engine: .init(
                    id: "context",
                    options: [:]
                ),
                output: .init(
                    path: "{{slug}}",
                    file: "context",
                    ext: "json"
                )
            ),
        ]
    }
}
