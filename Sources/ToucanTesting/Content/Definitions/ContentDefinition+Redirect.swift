import ToucanModels

public extension ContentDefinition.Mocks {

    static func redirect() -> ContentDefinition {
        .init(
            id: "redirect",
            paths: [],
            properties: [
                "to": .init(type: .string, required: true),
                "code": .init(type: .int, required: true, default: .init(301)),
            ],
            relations: [:],
            queries: [:]
        )
    }
}
