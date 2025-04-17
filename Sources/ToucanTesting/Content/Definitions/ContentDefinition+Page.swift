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
                    propertyType: .string,
                    isRequired: true,
                    defaultValue: nil
                ),
                "description": .init(
                    propertyType: .string,
                    isRequired: true,
                    defaultValue: nil
                ),
            ],
            relations: [:],
            queries: [:]
        )
    }
}
