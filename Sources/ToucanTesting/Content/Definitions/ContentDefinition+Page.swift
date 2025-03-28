import ToucanModels

public extension ContentDefinition.Mocks {

    static func page() -> ContentDefinition {
        .init(
            id: "page",
            default: true,
            paths: [
                "pages"
            ],
            properties: [
                "title": .init(
                    type: .string,
                    required: true,
                    default: nil
                ),
                "description": .init(
                    type: .string,
                    required: true,
                    default: nil
                ),
            ],
            relations: [:],
            queries: [:]
        )
    }
}
