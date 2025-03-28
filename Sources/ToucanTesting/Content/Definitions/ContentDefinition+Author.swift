import ToucanModels

public extension ContentDefinition.Mocks {

    static func author() -> ContentDefinition {
        .init(
            id: "author",
            paths: [
                "blog/authors"
            ],
            properties: [
                "name": .init(
                    type: .string,
                    required: true,
                    default: nil
                ),
                "description": .init(
                    type: .string,
                    required: false,
                    default: nil
                ),
            ],
            relations: [:],
            queries: [
                "posts": .init(
                    contentType: "post",
                    scope: "list",
                    limit: 100,
                    offset: 0,
                    filter: .field(
                        key: "authors",
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
