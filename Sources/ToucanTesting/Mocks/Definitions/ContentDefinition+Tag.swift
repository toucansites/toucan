import ToucanModels

public extension ContentDefinition.Mocks {

    static func tag() -> ContentDefinition {
        .init(
            type: "tag",
            paths: [
                "blog/tags"
            ],
            properties: [
                "name": .init(
                    type: .string,
                    required: true,
                    default: nil
                )
            ],
            relations: [:],
            queries: [
                "posts": .init(
                    contentType: "post",
                    scope: "???",
                    limit: 100,
                    offset: 0,
                    filter: .field(
                        key: "tags",
                        operator: .contains,
                        value: .init("{{id}}")
                    ),
                    orderBy: [
                        .init(key: "publication", direction: .desc)
                    ]
                )
            ]
        )
    }
}
