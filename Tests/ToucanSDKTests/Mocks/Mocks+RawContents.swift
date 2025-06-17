//
//  Mocks+RawContents.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 05. 21..
//

import Foundation
import ToucanSource

extension Mocks.RawContents {
    static func homePage(
        now: Date = .init()
    ) -> RawContent {
        .init(
            origin: .init(
                path: .init(""),
                slug: ""
            ),
            markdown: .init(
                frontMatter: [
                    "title": "Home page",
                    "description": "Home page description",
                ],
                contents: """
                # Home page

                Home page contents
                """
            ),
            lastModificationDate: now.timeIntervalSince1970,
            assets: []
        )
    }

    static func notFoundPage(
        now: Date = .init()
    ) -> RawContent {
        .init(
            origin: .init(
                path: .init("404"),
                slug: "404"
            ),
            markdown: .init(
                frontMatter: [
                    "type": "not-found",
                    "title": "Not found page",
                    "description": "Not found page description",
                ],
                contents: """
                # Not found

                Not found page contents
                """
            ),
            lastModificationDate: now.timeIntervalSince1970,
            assets: []
        )
    }

    static func aboutPage(
        now: Date = .init()
    ) -> RawContent {
        .init(
            origin: .init(
                path: .init("about"),
                slug: "about"
            ),
            markdown: .init(
                frontMatter: [
                    "title": "About page",
                    "description": "About page description",
                    "css": [
                        "/assets/about/about.css",
                        "https://unpkg.com/test@1.0.0.css",
                    ],
                ],
                contents: """
                # About page

                About page contents
                """
            ),
            lastModificationDate: now.timeIntervalSince1970,
            assets: [
                "style.css",
                "main.js",
            ]
        )
    }

    static func contextPage(
        now: Date = .init()
    ) -> RawContent {
        .init(
            origin: .init(
                path: .init("context"),
                slug: "context"
            ),
            markdown: .init(
                frontMatter: [
                    "title": "Context page",
                    "description": "Context page description",
                    "template": "pages.context",
                ],
                contents: """
                # Context page

                Context page contents
                """
            ),
            lastModificationDate: now.timeIntervalSince1970,
            assets: []
        )
    }

    static func redirectHome(
        now: Date = .init()
    ) -> RawContent {
        .init(
            origin: .init(
                path: .init("redirects/home-old"),
                slug: "home-old"
            ),
            markdown: .init(
                frontMatter: [
                    "type": "redirect",
                    "to": "",
                    "code": "301",
                ],
                contents: ""
            ),
            lastModificationDate: now.timeIntervalSince1970,
            assets: []
        )
    }

    static func redirectAbout(
        now: Date = .init()
    ) -> RawContent {
        .init(
            origin: .init(
                path: .init("redirects/about-old"),
                slug: "about-old"
            ),
            markdown: .init(
                frontMatter: [
                    "type": "redirect",
                    "to": "about",
                    "code": "301",
                ],
                contents: ""
            ),
            lastModificationDate: now.timeIntervalSince1970,
            assets: []
        )
    }

    static func rssXML(
        now: Date = .init()
    ) -> RawContent {
        .init(
            origin: .init(
                path: .init("rss.xml"),
                slug: "rss.xml"
            ),
            markdown: .init(
                frontMatter: [
                    "type": "rss",
                ],
                contents: ""
            ),
            lastModificationDate: now.timeIntervalSince1970,
            assets: []
        )
    }

    static func sitemapXML(
        now: Date = .init()
    ) -> RawContent {
        .init(
            origin: .init(
                path: .init("sitemap.xml"),
                slug: "sitemap.xml"
            ),
            markdown: .init(
                frontMatter: [
                    "type": "sitemap",
                ],
                contents: ""
            ),
            lastModificationDate: now.timeIntervalSince1970,
            assets: []
        )
    }

    // MARK: -

    static func page(
        id: Int,
        now: Date = .init()
    ) -> RawContent {
        .init(
            origin: .init(
                path: .init("pages/page-\(id)"),
                slug: "pages/page-\(id)"
            ),
            markdown: .init(
                frontMatter: [
                    "title": "Page #\(id)",
                    "description": "Page #\(id) description",
                ],
                contents: """
                # Page #\(id)

                Page #\(id) contents
                """
            ),
            lastModificationDate: now.timeIntervalSince1970,
            assets: []
        )
    }

    static func author(
        id: Int,
        age: Int = 21,
        now: Date = .init()
    ) -> RawContent {
        .init(
            origin: .init(
                path: .init("blog/authors/author-\(id)"),
                slug: "blog/authors/author-\(id)"
            ),
            markdown: .init(
                frontMatter: [
                    "name": "Author #\(id)",
                    "description": "Author #\(id) description",
                    "image": "./assets/author-\(id).jpg",
                    "age": .init(age),
                ],

                contents: """
                # Author #\(id)

                Author page contents
                """,
            ),
            lastModificationDate: now.timeIntervalSince1970,
            assets: [
                "author-\(id).jpg",
            ]
        )
    }

    static func tag(
        id: Int,
        now: Date = .init()
    ) -> RawContent {
        .init(
            origin: .init(
                path: .init("blog/tags/tag-\(id)"),
                slug: "blog/tags/tag-\(id)"
            ),
            markdown: .init(
                frontMatter: [
                    "title": "Tag \(id)",
                    "description": "Tag #\(id) description",
                ],

                contents: """
                # Tag #\(id)

                Tag page contents
                """,
            ),
            lastModificationDate: now.timeIntervalSince1970,
            assets: []
        )
    }

    static func post(
        id: Int,
        now: Date = .init(),
        publication: String,
        expiration: String,
        draft: Bool = false,
        featured: Bool = false,
        authorIDs: [Int] = [],
        tagIDs: [Int] = []
    ) -> RawContent {
        .init(
            origin: .init(
                path: .init("blog/posts/post-\(id)"),
                slug: "blog/posts/post-\(id)"
            ),
            markdown: .init(
                frontMatter: [
                    "title": "Post #\(id)",
                    "description": "Post #\(id) description",
                    "publication": .init(publication),
                    "expiration": .init(expiration),
                    "draft": .init(draft),
                    "featured": .init(featured),
                    "authors": .init(authorIDs.map { "author-\($0)" }),
                    "tags": .init(tagIDs.map { "tag-\($0)" }),
                    "rating": .init(Double(id)),
                    "image": "cover-\(id).jpg",
                ],

                contents: """
                # Post #\(id)

                Post page contents
                """,
            ),
            lastModificationDate: now.timeIntervalSince1970,
            assets: [
                "cover.jpg",
            ]
        )
    }

    static func postPagination(
        now: Date = .init()
    ) -> RawContent {
        .init(
            origin: .init(
                path: .init("blog/posts/pages/{{post.pagination}}"),
                slug: "blog/posts/pages/{{post.pagination}}"
            ),
            markdown: .init(
                frontMatter: [
                    "type": "page",
                    "title": "Post pagination page {{number}} / {{total}}",
                    "description": "Post pagination page description",
                ],

                contents: """
                # Post pagination page {{number}} / {{total}}

                Post pagination page contents
                """,
            ),
            lastModificationDate: now.timeIntervalSince1970,
            assets: []
        )
    }

    static func category(
        id: Int,
        now: Date = .init()
    ) -> RawContent {
        .init(
            origin: .init(
                path: .init("docs/categories/category-\(id)"),
                slug: "docs/categories/category-\(id)"
            ),
            markdown: .init(
                frontMatter: [
                    "title": "Category #\(id)",
                    "description": "Category #\(id) description",
                    "order": .init(id),
                ],

                contents: """
                # Category #\(id)

                Category page contents
                """,
            ),
            lastModificationDate: now.timeIntervalSince1970,
            assets: []
        )
    }

    static func guide(
        id: Int,
        categoryID: Int,
        now: Date = .init()
    ) -> RawContent {
        .init(
            origin: .init(
                path: .init("docs/guides/guide-\(id)"),
                slug: "docs/guides/guide-\(id)"
            ),
            markdown: .init(
                frontMatter: [
                    "title": "Guide #\(id)",
                    "description": "Guide #\(id) description",
                    "category": "category-\(categoryID)",
                    "order": .init(id),
                ],

                contents: """
                # Guide #\(id)

                Guide page contents
                """,
            ),
            lastModificationDate: now.timeIntervalSince1970,
            assets: []
        )
    }
}
