import ToucanModels

extension ContentDefinition.Mocks {

    static func author() -> ContentDefinition {
        .init(
            type: "author",
            paths: [
                "blog/authors"
            ],
            properties: [
                .init(
                    key: "name",
                    type: .string,
                    required: true,
                    default: nil
                ),
                .init(
                    key: "description",
                    type: .string,
                    required: false,
                    default: nil
                ),
            ],
            relations: [],
            queries: [
                "posts": .init(
                    contentType: "post",
                    scope: "list",
                    limit: 100,
                    offset: 0,
                    filter: .field(
                        key: "authors",
                        operator: .contains,
                        value: "{{id}}"
                    ),
                    orderBy: [
                        .init(key: "publication", direction: .desc)
                    ]
                )
            ]
        )
    }
}
