import ToucanModels
import ToucanSource

extension RenderPipeline.Mocks {

    static func defaults() -> [RenderPipeline] {
        [
            .init(
                queries: [
                    "featured": .init(
                        contentType: "post",
                        filter: .field(
                            key: "featured",
                            operator: .equals,
                            value: true
                        )
                    )
                ],
                contentType: .all,
                engine: .init(
                    id: "test",
                    options: [:]
                )
            )
        ]
    }
}
