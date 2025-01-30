import ToucanModels

extension ContentDefinition.Mocks {

    static func post() -> ContentDefinition {
        .init(
            type: "post",
            paths: [
                "blog/posts"
            ],
            properties: [
                "name": .init(
                    type: .string,
                    required: true,
                    default: nil
                ),
                "date": .init(
                    type: .date(format: "yyyy-MM-dd'T'HH:mm:ssZ"),
                    required: true,
                    default: nil
                ),
                "featured": .init(
                    type: .bool,
                    required: true,
                    default: false
                ),
            ],
            relations: [
                "authors": .init(
                    references: "author",
                    type: .many,
                    order: .init(key: "title", direction: .asc)
                ),
                "tags": .init(
                    references: "tag",
                    type: .many,
                    order: .init(key: "title", direction: .asc)
                ),
            ],
            queries: [
                "related": .init(
                    contentType: "post",
                    scope: "list",
                    limit: 4,
                    offset: 0,
                    filter: .field(
                        key: "tags",
                        operator: .in,
                        value: "{{tags}}"
                    ),
                    orderBy: []
                )
                // TODO: prev + next + more by authors (similar?)
            ]
        )
    }
}
