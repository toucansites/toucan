//
//  File.swift
//
//
//  Created by Tibor Bodecs on 10/05/2024.
//

import Foundation
import Mustache

extension String {

    func minifyHTML() -> String {
        self
    }
}

extension Site {

    func getContext() -> SiteContext {
        .init(
            baseUrl: baseUrl,
            title: title,
            language: language
        )
    }
}

extension Post {

    func getContext(
        formatter: DateFormatter
    ) -> PostContext {
        .init(
            title: meta.title,
            exceprt: meta.description,
            date: formatter.string(from: publication),
            figure: .init(
                src: meta.imageUrl ?? "",
                darkSrc: nil,
                alt: meta.title,
                title: meta.title
            )
        )
    }
}

struct TemplateLibrary {

    enum Error: Swift.Error {
        case missingTemplate(String)
    }

    private let site: Site
    private let library: MustacheLibrary
    private let ids: [String]

    init(
        site: Site,
        templatesUrl: URL
    ) throws {
        let ext = "mustache"
        var templates: [String: MustacheTemplate] = [:]

        if let dirContents = FileManager.default.enumerator(
            at: templatesUrl,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: [.skipsHiddenFiles]
        ) {
            for case let url as URL in dirContents
            where url.pathExtension == ext {
                var relativePathComponents = url.pathComponents.dropFirst(
                    templatesUrl.pathComponents.count
                )
                let name = String(
                    relativePathComponents.removeLast()
                        .dropLast(".\(ext)".count)
                )
                relativePathComponents.append(name)
                let id = relativePathComponents.joined(separator: ".")
                templates[id] = try MustacheTemplate(
                    string: .init(contentsOf: url)
                )
            }
        }
        self.site = site
        self.library = MustacheLibrary(templates: templates)
        self.ids = Array(templates.keys)
    }

    private func render(
        template: String,
        with object: Any
    ) throws -> String? {
        guard self.ids.contains(template) else {
            throw Error.missingTemplate(template)
        }
        return library.render(object, withTemplate: template)
    }

    private func render(
        template: String,
        with object: Any,
        to destination: URL
    ) throws {
        guard self.ids.contains(template) else {
            throw Error.missingTemplate(template)
        }
        try library.render(
            object,
            withTemplate: template
        )?
        .minifyHTML()
        .write(
            to: destination,
            atomically: true,
            encoding: .utf8
        )
    }

    // MARK: -

    func renderSingleTag(
        tag: Tag,
        body: String,
        to destination: URL
    ) throws {
        let formatter = DateFormatters().standard
        let context = PageContext(
            site: site.getContext(),
            metadata: .init(
                permalink: site.permalink(tag.slug),
                title: tag.meta.title,
                description: tag.meta.description,
                imageUrl: tag.meta.imageUrl
            ),
            content: SingleTagContext(
                title: tag.meta.title,
                description: tag.meta.description,
                posts: .init(
                    site.postsBy(tagId: tag.id)
                        .map {
                            $0.getContext(
                                formatter: formatter
                            )
                        }
                )
            ),
            userDefined: [:]
        )

        try render(
            template: "pages.single.tag",
            with: context,
            to: destination
        )
    }

    func renderSingleAuthor(
        author: Author,
        body: String,
        to destination: URL
    ) throws {
        let formatter = DateFormatters().standard
        let context = PageContext(
            site: site.getContext(),
            metadata: .init(
                permalink: site.permalink(author.slug),
                title: author.meta.title,
                description: author.meta.description,
                imageUrl: author.meta.imageUrl
            ),
            content: SingleAuthorContext(
                title: author.meta.title,
                description: author.meta.description,
                posts: .init(
                    site.postsBy(authorId: author.id)
                        .map {
                            $0.getContext(formatter: formatter)
                        }
                )
            ),
            userDefined: [:]
        )

        try render(
            template: "pages.single.author",
            with: context,
            to: destination
        )
    }

    func renderSinglePost(
        post: Post,
        body: String,
        to destination: URL
    ) throws {

        let context = PageContext(
            site: site.getContext(),
            metadata: .init(
                permalink: site.permalink(post.slug),
                title: post.meta.title,
                description: post.meta.description,
                imageUrl: post.meta.imageUrl
            ),
            content: SinglePostContext(
                title: post.meta.title,
                exceprt: post.meta.description,
                date: "\(post.publication)",  // TODO: date formatter
                figure: .init(
                    src: "http://lorempixel.com/light.jpg",
                    darkSrc: "http://lorempixel.com/dark.jpg",
                    alt: post.meta.title,
                    title: post.meta.title
                ),
                tags: .init([
                    .init(permalink: site.permalink("foo"), title: "Foo")
                ]),
                body: body
            ),
            userDefined: [:]
        )

        try render(
            template: "pages.single.post",
            with: context,
            to: destination
        )
    }

    func renderHomePage(
        to destination: URL
    ) throws {
        let formatter = DateFormatters().standard
        let page = site.page(id: "home")

        let context = PageContext(
            site: site.getContext(),
            metadata: .init(
                permalink: site.permalink(""),
                title: page?.meta.title ?? "Home",
                description: page?.meta.description ?? "Home page",
                imageUrl: nil
            ),
            content: HomeContext(
                // TODO: sort by & first N
                posts: .init(
                    site.posts.map {
                        $0.getContext(
                            formatter: formatter
                        )
                    }
                )
            ),
            userDefined: page?.variables ?? [:]
        )

        try render(
            template: "pages.home",
            with: context,
            to: destination
        )
    }

    func renderPostsPage(
        posts: [Post],
        pageIndex index: Int,
        pageCount count: Int,
        to destination: URL
    ) throws {
        let formatter = DateFormatters().standard
        let pageIndex = index + 1
        let context = PageContext(
            site: site.getContext(),
            metadata: .init(
                permalink: site.permalink("posts/page/\(pageIndex)"),
                title: "posts page 1",
                description: "posts page 1 description",
                imageUrl: nil
            ),
            content: PostsContext(
                posts: .init(
                    posts.map {
                        $0.getContext(formatter: formatter)
                    }
                ),
                pagination: .init(
                    (0..<count)
                        .map { idx in
                            let currentPageIndex = idx + 1
                            return .init(
                                name: "\(currentPageIndex)",
                                url: site.permalink(
                                    "posts/page/\(currentPageIndex)"
                                ),
                                isCurrent: index == idx
                            )
                        }
                )
            ),
            userDefined: [:]
        )

        try render(
            template: "pages.posts",
            with: context,
            to: destination
        )
    }

    func renderRSS(
        to destination: URL
    ) throws {

        let now = Date()
        let formatter = DateFormatters().rss

        let items: [RSSContext.ItemContext] = site.posts.map {
            .init(
                permalink: site.permalink(
                    $0.slug
                ),
                title: $0.meta.title,
                description: $0.meta.description,
                publicationDate: formatter.string(
                    from: $0.publication
                )
            )
        }

        let context = RSSContext(
            title: site.title,
            description: site.description,
            baseUrl: site.baseUrl,
            language: site.language,
            lastBuildDate: formatter.string(from: now),
            publicationDate: formatter.string(
                from: site.posts.first?.publication ?? now
            ),
            items: .init(items)
        )

        try render(
            template: "rss",
            with: context,
            to: destination
        )
    }

    func renderSitemap(
        to destination: URL
    ) throws {
        let formatter = DateFormatters().sitemap
        let context = SitemapContext(
            urls: .init(
                site.contents.map {
                    SitemapContext.URL(
                        location: site.permalink($0.slug),
                        lastModification: formatter.string(
                            from: $0.lastModification
                        )
                    )
                }
            )
        )

        try render(
            template: "sitemap",
            with: context,
            to: destination
        )
    }
}
