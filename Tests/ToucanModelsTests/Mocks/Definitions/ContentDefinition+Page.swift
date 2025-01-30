import ToucanModels

extension ContentDefinition.Mocks {

    static func page() -> ContentDefinition {
        .init(
            type: "page",
            paths: [
                "pages"
            ],
            properties: [
                .init(
                    key: "title",
                    type: .string,
                    required: true,
                    default: nil
                ),
                .init(
                    key: "description",
                    type: .string,
                    required: true,
                    default: nil
                ),
            ],
            relations: [],
            queries: [:]
        )
    }
}
