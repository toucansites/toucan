import ToucanModels

public extension ContentDefinition.Mocks {

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
                "publication": .init(
                    type: .date(format: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"),
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
                "prev": .init(
                    contentType: "post",
                    limit: 1,
                    filter: .field(
                        key: "publication",
                        operator: .lessThan,
                        value: "{{publication}}"
                    ),
                    orderBy: [
                        .init(
                            key: "publication",
                            direction: .desc
                        )
                    ]
                ),

                "next": .init(
                    contentType: "post",
                    limit: 1,
                    filter: .field(
                        key: "publication",
                        operator: .greaterThan,
                        value: "{{publication}}"
                    ),
                    orderBy: [
                        .init(
                            key: "publication",
                            direction: .asc
                        )
                    ]
                ),

                "related": .init(
                    contentType: "post",
                    scope: "list",
                    limit: 4,
                    filter: .and(
                        [
                            .field(
                                key: "id",
                                operator: .notEquals,
                                value: "{{id}}"
                            ),
                            .field(
                                key: "authors",
                                operator: .matching,
                                value: "{{authors}}"
                            ),
                        ]
                    ),
                    orderBy: []
                ),

                "similar": .init(
                    contentType: "post",
                    scope: "list",
                    limit: 4,
                    filter: .and(
                        [
                            .field(
                                key: "id",
                                operator: .notEquals,
                                value: "{{id}}"
                            ),
                            .field(
                                key: "tags",
                                operator: .matching,
                                value: "{{tags}}"
                            ),
                        ]
                    ),
                    orderBy: []
                ),
            ]
        )
    }
}
