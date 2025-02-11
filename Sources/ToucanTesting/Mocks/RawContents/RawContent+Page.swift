import Foundation
import ToucanModels

public extension RawContent.Mocks {

    static func pages(
        max: Int = 10
    ) -> [RawContent] {
        [
            .init(
                origin: .init(
                    path: "",
                    slug: ""
                ),
                frontMatter: [
                    "title": .init(
                        value: "Home"
                    ),
                    "description": .init(
                        value: "Home description"
                    ),
                    "foo": .init(
                        value: [
                            "bar": "baz"
                        ]
                    ),
                ],
                markdown: """
                    # Home

                    Lorem ipsum dolor sit amet
                    """,
                lastModificationDate: Date().timeIntervalSince1970,
                assets: []
            ),
            .init(
                origin: .init(
                    path: "404",
                    slug: "404"
                ),
                frontMatter: [
                    "title": .init(
                        value: "404"
                    ),
                    "description": .init(
                        value: "404 description"
                    ),
                ],
                markdown: """
                    # 404

                    Lorem ipsum dolor sit amet
                    """,
                lastModificationDate: Date().timeIntervalSince1970,
                assets: []
            ),
            .init(
                origin: .init(
                    path: "about",
                    slug: "about"
                ),
                frontMatter: [
                    "title": .init(
                        value: "About"
                    ),
                    "description": .init(
                        value: "About description"
                    ),
                ],
                markdown: """
                    # About

                    Lorem ipsum dolor sit amet
                    """,
                lastModificationDate: Date().timeIntervalSince1970,
                assets: []
            ),
        ]
            + (1...max)
            .map { i in
                .init(
                    origin: .init(
                        path: "pages/page-\(i)",
                        slug: "pages/page-\(i)"
                    ),
                    frontMatter: [
                        "title": .init(
                            value: "Page #\(i)"
                        ),
                        "description": .init(
                            value: "Page #\(i) description"
                        ),
                    ],
                    markdown: """
                        # Page #\(i)

                        Lorem ipsum dolor sit amet
                        """,
                    lastModificationDate: Date().timeIntervalSince1970,
                    assets: []
                )
            }
    }
}
