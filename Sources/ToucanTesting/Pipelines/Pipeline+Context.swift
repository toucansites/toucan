import ToucanModels
import ToucanSource

public extension Pipeline.Mocks {

    static func context() -> Pipeline {
        .init(
            id: "context",
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
                        "full": .init(format: "y.m.d.")
                    ]
                )
            ),
            contentTypes: .init(
                include: [],
                exclude: [],
                lastUpdate: []
            ),
            iterators: [
                "post.pagination": .init(
                    contentType: "post",
                    limit: 2
                )
            ],
            transformers: [:],
            engine: .init(
                id: "context",
                options: [:]
            ),
            output: .init(
                path: "_contexts/{{slug}}",
                file: "context",
                ext: "json"
            )
        )
    }
}
