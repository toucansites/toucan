import ToucanModels
import ToucanSource

public extension Pipeline.Mocks {

    static func redirect() -> Pipeline {
        .init(
            scopes: [:],
            queries: [:],
            dataTypes: .defaults,
            contentTypes: .init(
                include: [
                    "redirect"
                ],
                exclude: [],
                lastUpdate: []
            ),
            iterators: [:],
            transformers: [:],
            engine: .init(
                id: "mustache",
                options: [
                    "contentTypes": [
                        "redirect": [
                            "template": "redirect"
                        ]
                    ]
                ]
            ),
            output: .init(
                path: "{{slug}}",
                file: "index",
                ext: "html"
            )
        )
    }
}
