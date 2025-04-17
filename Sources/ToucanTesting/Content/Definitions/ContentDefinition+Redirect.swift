import ToucanModels

public extension ContentDefinition.Mocks {

    static func redirect() -> ContentDefinition {
        .init(
            id: "redirect",
            paths: [],
            properties: [
                "to": .init(propertyType: .string, isRequired: true),
                "code": .init(
                    propertyType: .int,
                    isRequired: true,
                    defaultValue: .init(301)
                ),
            ],
            relations: [:],
            queries: [:]
        )
    }
}
