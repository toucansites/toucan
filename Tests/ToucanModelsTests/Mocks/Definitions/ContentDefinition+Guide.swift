import ToucanModels

extension ContentDefinition.Mocks {

    static func guide() -> ContentDefinition {
        .init(
            type: "guide",
            paths: [
                "docs/guides"
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
            relations: [
                .init(
                    key: "category",
                    references: "category",
                    type: .one,
                    order: .init(key: "name", direction: .asc)
                )
            ],
            queries: [:]
        )
    }
}
