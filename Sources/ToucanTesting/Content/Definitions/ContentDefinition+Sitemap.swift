import ToucanModels

public extension ContentDefinition.Mocks {

    static func sitemap() -> ContentDefinition {
        .init(
            id: "sitemap",
            paths: [],
            properties: [:],
            relations: [:],
            queries: [:]
        )
    }
}
