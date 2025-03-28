import Foundation
import ToucanModels

public extension RawContent.Mocks {

    static func categories(
        max: Int = 10
    ) -> [RawContent] {
        (1...max)
            .map { i in
                .init(
                    origin: .init(
                        path: "docs/categories/category-\(i)",
                        slug: "docs/categories/category-\(i)"
                    ),
                    frontMatter: [
                        "title": "Category #\(i)",
                        "order": .init(i),
                    ],
                    markdown: """
                        # Category #\(i)

                        Lorem ipsum dolor sit amet
                        """,
                    lastModificationDate: Date().timeIntervalSince1970,
                    assets: []
                )
            }
    }
}
