import Foundation
import ToucanModels

extension RawContent.Mocks {

    static func posts(
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
                        "name": "Post \(i)",
                        "date": "2022-01-31T02:22:40+00:00",
                        "featured": (i % 2 == 0),
                        "authors": [(i / 2)].map { "author-\($0)" },
                        "tags": [(i / 2)].map { "tag-\($0)" },
                    ],
                    markdown: """
                        # Post #\(i)

                        Lorem ipsum dolor sit amet
                        """,
                    lastModificationDate: Date().timeIntervalSince1970,
                    assets: []
                )
            }
    }
}
