import ToucanModels
import ToucanSource
import ToucanCodable

public extension RenderPipeline.Mocks {

    static func defaults() -> [RenderPipeline] {
        [
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
                    filter: [
                        // page
                    ],
                    lastUpdate: [
                        "post",
                        "foo",
                    ]
                ),
                // are iterators are always pages? iteratorPages? 🤔
                iterators: [  // segments
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
                                "template": "post.default.template"
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
                            value: true
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
                contentTypes: .init(
                    filter: [
                        "post"
                    ],
                    lastUpdate: []
                ),
                iterators: [  // segments
                    "post.pagination": .init(
                        contentType: "post",
                        limit: 2
                    )
                ],
                engine: .init(
                    id: "context",
                    options: [:]
                ),
                output: .init(
                    path: "api/{{slug}}",
                    file: "context",
                    ext: "json"
                )
            ),
        ]
    }
}
