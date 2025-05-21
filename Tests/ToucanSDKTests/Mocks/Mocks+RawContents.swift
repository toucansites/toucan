//
//  File.swift
//  toucan
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
                path: "",
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
                path: "404",
                slug: "404"
            ),
            markdown: .init(
                frontMatter: [
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
                path: "about",
                slug: "about"
            ),
            markdown: .init(
                frontMatter: [
                    "title": "About page",
                    "description": "About page description",
                ],
                contents: """
                    # About page

                    About page contents
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
                path: "redirects/home-old",
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
                path: "redirects/about-old",
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
                path: "rss.xml",
                slug: "rss.xml"
            ),
            markdown: .init(
                frontMatter: [
                    "type": "rss"
                ],
                contents: ""
            ),
            lastModificationDate: now.timeIntervalSince1970,
            assets: []
        )
    }

    func sitemapXML(
        now: Date = .init()
    ) -> RawContent {
        .init(
            origin: .init(
                path: "sitemap.xml",
                slug: "sitemap.xml"
            ),
            markdown: .init(
                frontMatter: [
                    "type": "sitemap"
                ],
                contents: ""
            ),
            lastModificationDate: now.timeIntervalSince1970,
            assets: []
        )
    }

    // MARK: -

    mutating func page(
        id: Int,
        now: Date = .init()
    ) -> RawContent {
        .init(
            origin: .init(
                path: "pages/page-\(id)",
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

    mutating func buildAuthor(
        id: Int,
        now: Date = .init()
    ) -> RawContent {
        .init(
            origin: .init(
                path: "blog/authors/author-\(id)",
                slug: "blog/authors/author-\(id)"
            ),
            markdown: .init(
                frontMatter: [
                    "name": "Author #\(id)",
                    "description": "Author #\(id) description",
                    "age": .init(Int.random(in: 18...49)),
                ],

                contents: """
                    # Author #\(id)

                    Author page contents
                    """,
            ),
            lastModificationDate: now.timeIntervalSince1970,
            assets: []
        )
    }

    mutating func buildTag(
        id: Int,
        now: Date = .init()
    ) -> RawContent {
        .init(
            origin: .init(
                path: "blog/tags/tag-\(id)",
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

    mutating func buildPost(
        id: Int,
        now: Date = .init(),
        featured: Bool = false,
        authorIds: [Int] = [],
        tagIds: [Int] = []
    ) -> RawContent {
        .init(
            origin: .init(
                path: "blog/posts/post-\(id)",
                slug: "blog/posts/post-\(id)"
            ),
            markdown: .init(
                frontMatter: [
                    "title": "Post #\(id)",
                    "description": "Post #\(id) description",
                    "publication": .init(now),
                    "featured": .init(featured),
                    "authors": .init(authorIds.map { "author-\($0)" }),
                    "tags": .init(tagIds.map { "tag-\($0)" }),
                ],

                contents: """
                    # Post #\(id)

                    Post page contents
                    """,
            ),
            lastModificationDate: now.timeIntervalSince1970,
            assets: []
        )
    }

    func buildPostPagination(
        id: Int,
        now: Date = .init()
    ) -> RawContent {
        .init(
            origin: .init(
                path: "blog/posts/pages/{{post.pagination}}",
                slug: "blog/posts/pages/{{post.pagination}}"
            ),
            markdown: .init(
                frontMatter: [
                    "title": "Post pagination page",
                    "description": "Post pagination page description",
                ],

                contents: """
                    # Post pagination page

                    Post pagination page contents
                    """,
            ),
            lastModificationDate: now.timeIntervalSince1970,
            assets: []
        )
    }

    mutating func buildCategory(
        id: Int,
        now: Date = .init()
    ) -> RawContent {
        .init(
            origin: .init(
                path: "docs/categories/category-\(id)",
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

    mutating func buildGuide(
        id: Int,
        categoryId: Int,
        now: Date = .init()
    ) -> RawContent {
        .init(
            origin: .init(
                path: "docs/guides/guide-\(id)",
                slug: "docs/guides/guide-\(id)"
            ),
            markdown: .init(
                frontMatter: [
                    "title": "Guide #\(id)",
                    "description": "Guide #\(id) description",
                    "category": "category-\(categoryId)",
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
