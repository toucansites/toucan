import ToucanModels
import ToucanSource

public extension RenderPipeline.Mocks {

    static func defaults() -> [RenderPipeline] {
        return [
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
                contentType: .all,
                engine: .init(
                    id: "context",
                    options: [
                        "dataTypes": [
                            "date": [
                                "formats": [
                                    "full": "y.m.d.",
                                    "iso": "",
                                ]
                            ]
                        ],
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
                                // keep here or move up? :think:
                                "output": [
                                    "path": "{{slug}}",
                                    "file": "{{id}}",
                                    "ext": "json",
                                ],
                            ]
                        ],
                    ]
                )
            )
        ]
    }
}
