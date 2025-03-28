import ToucanModels

public extension ContentDefinition.Mocks {

    static func guide() -> ContentDefinition {
        .init(
            id: "guide",
            paths: [
                "docs/guides"
            ],
            properties: [
                "title": .init(
                    type: .string,
                    required: true,
                    default: nil
                ),
                "order": .init(
                    type: .int,
                    required: false,
                    default: .init(100)
                ),
            ],
            relations: [
                "category": .init(
                    references: "category",
                    type: .one,
                    order: .init(key: "name", direction: .asc)
                )
            ],
            queries: [:]
        )
    }
}
