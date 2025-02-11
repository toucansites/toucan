import Foundation
import ToucanModels

public extension RawContent.Mocks {

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
                        "name": .init(
                            value: "Author #\(i)"
                        ),
                        "description": .init(
                            value: "Author #\(i) description"
                        ),
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
