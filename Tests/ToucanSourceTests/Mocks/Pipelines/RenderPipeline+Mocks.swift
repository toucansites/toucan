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
                    "post": [
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
