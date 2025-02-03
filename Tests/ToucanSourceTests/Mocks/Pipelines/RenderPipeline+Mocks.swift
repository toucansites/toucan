import ToucanModels
import ToucanSource

extension RenderPipeline.Mocks {

    static func defaults() -> [RenderPipeline] {

        let options: [String: Any] = [
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

        return [
            .init(
                scopes: [
                    "*": [
                        .init(
                            id: "reference",
                            context: [.properties],
                            fields: []
                        ),
                        .init(
                            id: "list",
                            context: [.properties, .relations],
                            fields: []
                        ),
                        .init(
                            id: "detail",
                            context: .all,
                            fields: []
                        ),
                        .init(
                            id: "custom",
                            context: .properties,
                            fields: ["featured"]
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
                contentType: .all,
                engine: .init(
                    id: "test",
                    options: .init(
                        value: options
                    )
                )
            )
        ]
    }
}
