//
//  File.swift
//
//
//  Created by Tibor Bodecs on 10/05/2024.
//

import Foundation
import Mustache
import Markdown

extension String {

    func minifyHTML() -> String {
        self
        //        components(separatedBy: .newlines)
        //            .map { $0.trimmingCharacters(in: .whitespaces) }
        //            .joined()
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

    func figureContext(
        assets: Assets
    ) -> FigureContext? {
        guard let url = assets.url(meta.coverImage, for: .post) else {
            return nil
        }
        return .init(
            src: url,
            darkSrc: assets.url(meta.coverImage, for: .post, variant: .dark),
            alt: meta.title,
            title: meta.title
        )
    }

    func getContext(
        site: Site,
        assets: Assets,
        formatter: DateFormatter
    ) -> PostContext {
        .init(
            permalink: site.permalink("posts/" + slug),
            title: meta.title,
            exceprt: meta.description,
            date: formatter.string(from: publication),
            figure: figureContext(assets: assets)
        )
    }
}

extension Author {

    func figureContext(
        assets: Assets
    ) -> FigureContext? {
        guard let url = assets.url(meta.coverImage, for: .author) else {
            return nil
        }
        return .init(
            src: url,
            darkSrc: assets.url(meta.coverImage, for: .author, variant: .dark),
            alt: meta.title,
            title: meta.title
        )
    }

    func getContext(
        site: Site,
        assets: Assets
    ) -> AuthorContext {
        .init(
            permalink: site.permalink("authors/" + slug),
            title: meta.title,
            description: meta.description,
            figure: figureContext(assets: assets)
        )
    }
}

extension Tag {

    func figureContext(
        assets: Assets
    ) -> FigureContext? {
        guard let url = assets.url(meta.coverImage, for: .tag) else {
            return nil
        }
        return .init(
            src: url,
            darkSrc: assets.url(meta.coverImage, for: .tag, variant: .dark),
            alt: meta.title,
            title: meta.title
        )
    }

    func getContext(
        site: Site,
        assets: Assets
    ) -> TagContext {
        .init(
            permalink: site.permalink("tags/" + slug),
            title: meta.title,
            description: meta.description,
            figure: figureContext(assets: assets)
        )
    }
}

struct TemplateLibrary {

    enum Error: Swift.Error {
        case missingTemplate(String)
    }

    private let site: Site
    private let assets: Assets
    private let library: MustacheLibrary
    private let ids: [String]

    init(
        site: Site,
        assets: Assets,
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
        self.assets = assets
        self.library = MustacheLibrary(templates: templates)
        self.ids = Array(templates.keys)
    }

    // TODO: use thsi?
    func postsContexts(formatter: DateFormatter) -> [PostContext] {
        site.posts.map {
            $0.getContext(
                site: site,
                assets: assets,
                formatter: formatter
            )
        }
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
        guard ids.contains(template) else {
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

    func renderSinglePage(
        page: Page,
        body: String,
        to destination: URL
    ) throws {
        let context = ContentContext(
            site: site.getContext(),
            metadata: .init(
                permalink: site.permalink(page.slug),
                title: page.meta.title,
                description: page.meta.description,
                imageUrl: assets.url(page.meta.coverImage, for: .post)
            ),
            content: SingleCustomPageContext(
                title: page.meta.title,
                description: page.meta.description,
                body: body
            ),
            userDefined: page.frontMatter
        )

        try render(
            template: page.meta.template ?? "pages.single.page",
            with: context,
            to: destination
        )
    }

    func renderSingleTag(
        tag: Tag,
        body: String,
        to destination: URL
    ) throws {
        let formatter = DateFormatters().standard
        let context = ContentContext(
            site: site.getContext(),
            metadata: .init(
                permalink: site.permalink(tag.slug),
                title: tag.meta.title,
                description: tag.meta.description,
                imageUrl: assets.url(tag.meta.coverImage, for: .tag)
            ),
            content: SingleTagPageContext(
                tag: tag.getContext(site: site, assets: assets),
                posts: site.postsBy(tagId: tag.id)
                    .map {
                        $0.getContext(
                            site: site,
                            assets: assets,
                            formatter: formatter
                        )
                    }
            ),
            userDefined: tag.frontMatter
        )

        try render(
            template: tag.meta.template ?? "pages.single.tag",
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
        let context = ContentContext(
            site: site.getContext(),
            metadata: .init(
                permalink: site.permalink(author.slug),
                title: author.meta.title,
                description: author.meta.description,
                imageUrl: assets.url(author.meta.coverImage, for: .author)
            ),
            content: SingleAuthorPageContext(
                author: author.getContext(site: site, assets: assets),
                posts: site.postsBy(authorId: author.id)
                    .map {
                        $0.getContext(
                            site: site,
                            assets: assets,
                            formatter: formatter
                        )
                    }
            ),
            userDefined: author.frontMatter
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
        let formatter = DateFormatters().standard
        let context = ContentContext(
            site: site.getContext(),
            metadata: .init(
                permalink: site.permalink(post.slug),
                title: post.meta.title,
                description: post.meta.description,
                imageUrl: assets.url(post.meta.coverImage, for: .post)
            ),
            content: SinglePostPageContext(
                title: post.meta.title,
                exceprt: post.meta.description,
                date: formatter.string(from: post.publication),
                figure: post.figureContext(assets: assets),
                tags: site.tagsBy(ids: post.tagIds)
                    .map {
                        $0.getContext(
                            site: site,
                            assets: assets
                        )
                    },

                authors: site.authorsBy(ids: post.authorIds)
                    .map {
                        $0.getContext(
                            site: site,
                            assets: assets
                        )
                    },
                body: body
            ),
            userDefined: post.frontMatter
        )

        try render(
            template: post.meta.template ?? "pages.single.post",
            with: context,
            to: destination
        )
    }

    func renderAuthorsPage(
        to destination: URL
    ) throws {
        let page = site.page(id: "authors")

        let context = ContentContext(
            site: site.getContext(),
            metadata: .init(
                permalink: site.permalink(page?.slug ?? "authors"),
                title: page?.meta.title ?? "Authors",
                description: page?.meta.description ?? "Authors page",
                imageUrl: assets.url(page?.meta.coverImage, for: .page)
            ),
            content: AuthorsPageContext(
                authors: site.authors.map {
                    $0.getContext(
                        site: site,
                        assets: assets
                    )
                }
            ),
            userDefined: page?.frontMatter ?? [:]
        )

        try render(
            template: page?.meta.template ?? "pages.authors",
            with: context,
            to: destination
        )
    }

    func renderTagsPage(
        to destination: URL
    ) throws {
        let page = site.page(id: "tags")

        let context = ContentContext(
            site: site.getContext(),
            metadata: .init(
                permalink: site.permalink(page?.slug ?? "tags"),
                title: page?.meta.title ?? "Tags",
                description: page?.meta.description ?? "Tags page",
                imageUrl: assets.url(page?.meta.coverImage, for: .page)
            ),
            content: TagsPageContext(
                tags: site.tags.map {
                    $0.getContext(
                        site: site,
                        assets: assets
                    )
                }
            ),
            userDefined: page?.frontMatter ?? [:]
        )

        try render(
            template: page?.meta.template ?? "pages.tags",
            with: context,
            to: destination
        )
    }

    func renderHomePage(
        to destination: URL
    ) throws {
        let formatter = DateFormatters().standard
        let page = site.page(id: "home")

        let context = ContentContext(
            site: site.getContext(),
            metadata: .init(
                permalink: site.permalink(page?.slug ?? ""),
                title: page?.meta.title ?? "Home",
                description: page?.meta.description ?? "Home page",
                imageUrl: assets.url(page?.meta.coverImage, for: .page)
            ),
            content: HomePageContext(
                // TODO: first N
                posts: site.posts.map {
                    $0.getContext(
                        site: site,
                        assets: assets,
                        formatter: formatter
                    )
                }
            ),
            userDefined: page?.frontMatter ?? [:]
        )

        try render(
            template: page?.meta.template ?? "pages.home",
            with: context,
            to: destination
        )
    }

    func renderNotFoundPage(
        to destination: URL
    ) throws {
        let formatter = DateFormatters().standard
        let page = site.page(id: "404")

        let context = ContentContext(
            site: site.getContext(),
            metadata: .init(
                permalink: site.permalink(page?.slug ?? "not-found"),
                title: page?.meta.title ?? "Not found",
                description: page?.meta.description ?? "Page not found",
                imageUrl: assets.url(page?.meta.coverImage, for: .page)
            ),
            content: HomePageContext(
                // TODO: first N
                posts: site.posts.map {
                    $0.getContext(
                        site: site,
                        assets: assets,
                        formatter: formatter
                    )
                }
            ),
            userDefined: page?.frontMatter ?? [:]
        )

        try render(
            template: page?.meta.template ?? "pages.404",
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
        let page = site.page(id: "posts")

        let formatter = DateFormatters().standard
        let pageIndex = index + 1
        let context = ContentContext(
            site: site.getContext(),
            metadata: .init(
                permalink: site.permalink("posts/page/\(pageIndex)"),
                title: page?.meta.title ?? "Posts - \(pageIndex)",
                description: page?.meta.description ?? "Posts - \(pageIndex)",
                imageUrl: assets.url(page?.meta.coverImage, for: .page)
            ),
            content: PostsPageContext(
                posts: posts.map {
                    $0.getContext(
                        site: site,
                        assets: assets,
                        formatter: formatter
                    )
                },
                pagination: (0..<count)
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
            ),
            userDefined: [:]
        )

        try render(
            template: page?.meta.template ?? "pages.posts",
            with: context,
            to: destination
        )
    }

    func renderRSS(
        to destination: URL
    ) throws {

        let now = Date()
        let formatter = DateFormatters().rss

        let context = RSSContext(
            title: site.title,
            description: site.description,
            baseUrl: site.baseUrl,
            language: site.language,
            lastBuildDate: formatter.string(from: now),
            publicationDate: formatter.string(
                from: site.posts.first?.publication ?? now
            ),
            items: site.posts.map {
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
            urls: site.contents.map {
                SitemapContext.URL(
                    location: site.permalink($0.slug),
                    lastModification: formatter.string(
                        from: $0.lastModification
                    )
                )
            }
        )

        try render(
            template: "sitemap",
            with: context,
            to: destination
        )
    }
}

struct ContentTypeRendererDelegate: HTMLRenderer.Delegate {

    let site: Site
    let assets: Assets
    let contentType: ContentType

    func linkAttributes(_ link: String?) -> [String: String] {
        var attributes: [String: String] = [:]
        guard let link, !link.isEmpty else {
            return attributes
        }
        if !link.hasPrefix("."),
            !link.hasPrefix("/"),
            !link.hasPrefix(site.baseUrl)
        {
            attributes["target"] = "_blank"
        }
        return attributes
    }

    func imageOverride(_ image: Image) -> String? {
        guard
            let source = image.source,
            source.hasPrefix("."),
            let url = assets.url(source, for: contentType)
        else {
            return nil
        }
        var drk = ""
        if let darkUrl = assets.url(source, for: contentType, variant: .dark) {
            drk =
                #"<source srcset="\#(darkUrl)" media="(prefers-color-scheme: dark)">\#n\#t\#t"#
        }
        var title = ""
        if let ttl = image.title {
            title = #" title="\#(ttl)""#
        }
        return #"""
                <figure>
                   <picture>
                       \#(drk)<img class="post-image" src="\#(url)" alt="\#(image.plainText)"\#(title)>
                   </picture>
                </figure>
            """#
    }
}
