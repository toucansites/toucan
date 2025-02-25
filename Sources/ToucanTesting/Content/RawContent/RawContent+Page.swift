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
                    "title": "Home",
                    "description": "Home description",
                    "foo": ["bar": "baz"],
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
                    "title": "404",
                    "description": "404 description",
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
                    "title": "About",
                    "description": "About description",
                ],
                markdown: """
                    # About

                    Lorem ipsum dolor sit amet
                    """,
                lastModificationDate: Date().timeIntervalSince1970,
                assets: []
            ),
            .init(
                origin: .init(
                    path: "blog/posts/pages/{{post.pagination}}",
                    slug: "blog/posts/pages/{{post.pagination}}"
                ),
                frontMatter: [
                    "title": "Post pagination",
                    "description": "Post pagination",
                ],
                markdown: """
                    # Posts

                    List posts here...
                    """,
                lastModificationDate: Date().timeIntervalSince1970,
                assets: []
            ),
        ]
            
        +
        
        (1...max).map { i in
            .init(
                origin: .init(
                    path: "pages/page-\(i)",
                    slug: "pages/page-\(i)"
                ),
                frontMatter: [
                    "title": "Page #\(i)",
                    "description": "Page #\(i) description",
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
