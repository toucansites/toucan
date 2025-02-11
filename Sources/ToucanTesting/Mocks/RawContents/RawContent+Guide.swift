import Foundation
import ToucanModels

extension RawContent.Mocks {

    static func guides(
        max: Int = 10
    ) -> [RawContent] {
        (1...max)
            .map { i in
                .init(
                    origin: .init(
                        path: "docs/guides/guide-\(i)",
                        slug: "docs/guides/guide-\(i)"
                    ),
                    frontMatter: [
                        "name": .init(value: "Guide #\(i)"),
                        "category": .init(value: "category-\(i)"),
                        "order": .init(value: i),
                    ],
                    markdown: """
                        # Guide #\(i)

                        Lorem ipsum dolor sit amet
                        """,
                    lastModificationDate: Date().timeIntervalSince1970,
                    assets: []
                )
            }
    }
}
