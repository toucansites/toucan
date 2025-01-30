import Foundation
import ToucanModels

extension RawContent.Mocks {

    static func authors(
        max: Int = 10
    ) -> [RawContent] {
        (1...max)
            .map { i in
                .init(
                    origin: .init(
                        path: "blog/authors/author-\(i)",
                        slug: "blog/authors/author-\(i)"
                    ),
                    frontMatter: [
                        "name": "Author \(i)",
                        "description": "Author description \(i)",
                    ],
                    markdown: """
                        # Author #\(i)

                        Lorem ipsum dolor sit amet
                        """,
                    lastModificationDate: Date().timeIntervalSince1970,
                    assets: []
                )
            }
    }
}
