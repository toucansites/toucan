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
            name: name,
            language: language
        )
    }
}

extension Post {

    func getContext() -> PostContext {
        .init(
            title: metatags.title,
            exceprt: metatags.description,
            date: "\(publication)",
            figure: .init(
                src: metatags.imageUrl ?? "",
                darkSrc: nil,
                alt: metatags.title,
                title: metatags.title
            )
        )
    }
}

struct TemplateLibrary {

    enum Error: Swift.Error {
        case missingTemplate(String)
    }

    private let library: MustacheLibrary
    private let ids: [String]

    init(
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
        site: Site,
        tag: Tag,
        body: String,
        to destination: URL
    ) throws {
        let context = PageContext(
            site: site.getContext(),
            metadata: .init(
                permalink: site.permalink(tag.slug),
                title: tag.metatags.title,
                description: tag.metatags.description,
                imageUrl: tag.metatags.imageUrl
            ),
            content: SingleTagContext(
                name: tag.metatags.title,
                description: tag.metatags.description,
                posts: .init(
                    site.postsBy(tagId: tag.id).map { $0.getContext() }
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
        site: Site,
        author: Author,
        body: String,
        to destination: URL
    ) throws {

        let context = PageContext(
            site: site.getContext(),
            metadata: .init(
                permalink: site.permalink(author.slug),
                title: author.metatags.title,
                description: author.metatags.description,
                imageUrl: author.metatags.imageUrl
            ),
            content: SingleAuthorContext(
                name: author.metatags.title,
                description: author.metatags.description,
                posts: .init(
                    site.postsBy(authorId: author.id).map { $0.getContext() }
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
        site: Site,
        post: Post,
        body: String,
        to destination: URL
    ) throws {

        let context = PageContext(
            site: site.getContext(),
            metadata: .init(
                permalink: site.permalink(post.slug),
                title: post.metatags.title,
                description: post.metatags.description,
                imageUrl: post.metatags.imageUrl
            ),
            content: SinglePostContext(
                title: post.metatags.title,
                exceprt: post.metatags.description,
                date: "\(post.publication)",  // TODO: date formatter
                figure: .init(
                    src: "http://lorempixel.com/light.jpg",
                    darkSrc: "http://lorempixel.com/dark.jpg",
                    alt: post.metatags.title,
                    title: post.metatags.title
                ),
                tags: .init([
                    .init(permalink: site.permalink("foo"), name: "Foo")
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
        site: Site,
        to destination: URL
    ) throws {

        let page = site.page(id: "home")

        let context = PageContext(
            site: site.getContext(),
            metadata: .init(
                permalink: site.permalink(""),
                title: page?.metatags.title ?? "Home",
                description: page?.metatags.description ?? "Home page",
                imageUrl: nil
            ),
            content: HomeContext(
                // TODO: sort by & first N
                posts: .init(site.posts.map { $0.getContext() })
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
        site: Site,
        posts: [Post],
        pageIndex index: Int,
        pageCount count: Int,
        to destination: URL
    ) throws {
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
                posts: .init(posts.map { $0.getContext() }),
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
        site: Site,
        posts: [Post],
        to destination: URL
    ) throws {
        let context = RSSContext(posts: .init(posts.map { $0.getContext() }))

        try render(
            template: "rss",
            with: context,
            to: destination
        )
    }

    func renderSitemap(
        site: Site,
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
