import ToucanModels

extension ContentDefinition.Mocks {

    static func category() -> ContentDefinition {
        .init(
            type: "category",
            paths: [
                "docs/categories"
            ],
            properties: [
                .init(
                    key: "name",
                    type: .string,
                    required: true,
                    default: nil
                ),
                .init(
                    key: "order",
                    type: .int,
                    required: false,
                    default: 100
                ),
            ],
            relations: [],
            queries: [
                "guides": .init(
                    contentType: "guide",
                    scope: "???",
                    limit: 100,
                    offset: 0,
                    filter: .field(
                        key: "category",
                        operator: .equals,
                        value: "{{id}}"
                    ),
                    orderBy: [
                        .init(key: "order", direction: .desc)
                    ]
                )
            ]
        )
    }
}
