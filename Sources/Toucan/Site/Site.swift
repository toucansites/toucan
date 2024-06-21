//
//  File.swift
//
//
//  Created by Tibor Bodecs on 03/05/2024.
//

import Foundation
import Algorithms

struct Site {

    enum Error: Swift.Error {
        case missingPage(String)
    }

    let source: Source
    let destinationUrl: URL

    let currentYear: Int
    let dateFormatter: DateFormatter
    let rssDateFormatter: DateFormatter
    let sitemapDateFormatter: DateFormatter
    
    let content: Site.Content

    init(
        source: Source,
        destinationUrl: URL
    ) {
        self.source = source
        self.destinationUrl = destinationUrl

        let calendar = Calendar(identifier: .gregorian)
        self.currentYear = calendar.component(.year, from: .init())

        self.dateFormatter = DateFormatters.baseFormatter
        self.dateFormatter.dateFormat = source.config.site.dateFormat
        self.rssDateFormatter = DateFormatters.rss
        self.sitemapDateFormatter = DateFormatters.sitemap
        
        
        let posts: [Content.Blog.Post] = source.contents.blog.posts.map {
            .init(
                content: $0,
                config: source.config,
                dateFormatter: DateFormatters.baseFormatter
            )
        }

        self.content = .init(
            blog: .init(
                posts: posts,
                authors: source.contents.blog.authors
                    .map { author in
                            .init(
                                content: author,
                                posts: posts.filter {
                                    $0.authors.contains(author.slug)
                                }
                            )
                    },
                tags: source.contents.blog.tags
                    .map { tag in
                            .init(
                                content: tag,
                                posts: posts.filter {
                                    $0.tags.contains(tag.slug)
                                }
                            )
                    }
            )
        )
    }

    // MARK: - utilities

    var baseUrl: String { source.config.site.baseUrl }

    func permalink(_ value: String) -> String {
        let components = value.split(separator: "/").map(String.init)
        if components.isEmpty {
            return baseUrl
        }
        if components.last?.split(separator: ".").count ?? 0 > 1 {
            return baseUrl + components.joined(separator: "/")
        }
        return baseUrl + components.joined(separator: "/") + "/"
    }
    
    func figureState(
        for path: String?,
        folder: String,
        alt: String? = nil,
        title: String? = nil
    ) -> Context.Figure? {
        guard
            let url = source.assets.url(
                for: path,
                folder: folder,
                permalink: permalink(_:)
            )
        else {
            return nil
        }
        return .init(
            src: url,
            darkSrc: source.assets.url(
                for: path,
                folder: folder,
                variant: .dark,
                permalink: permalink(_:)
            ),
            alt: alt,
            title: title
        )
    }

    func metadata(
        for content: Source.Content
    ) -> Context.Metadata {
        .init(
            slug: content.slug,
            permalink: permalink(content.slug),
            title: content.title,
            description: content.description,
            imageUrl: source.assets.url(
                for: content.coverImage,
                folder: content.assetsFolder,
                permalink: permalink(_:)
            )
        )
    }

    func render(
        markdown: String,
        folder: String
    ) -> String {
        let renderer = MarkdownToHTMLRenderer(
            delegate: HTMLRendererDelegate(
                site: self,
                folder: folder
            )
        )
        return renderer.render(markdown: markdown)
    }

    func readingTime(_ value: String) -> Int {
        value.split(separator: " ").count / 238
    }
    
    // MARK: - context helpers

    func getContext() -> Context.Site {
        .init(
            baseUrl: source.config.site.baseUrl,
            title: source.config.site.title,
            description: source.config.site.description,
            language: source.config.site.language
        )
    }
    
    // MARK: - site page renderables
    
    func home() -> Renderable<Output.HTML<Context.Main.Home>> {
        let context = Output.HTML<Context.Main.Home>
            .init(
                site: getContext(),
                page: .init(
                    metadata: metadata(for: source.contents.pages.main.home),
                    context: .init(
                        featured: [],
                        posts: [],
                        authors: [],
                        tags: [],
                        pages: []
                    ),
                    content: render(
                        markdown: source.contents.pages.main.home.markdown,
                        folder: source.contents.pages.main.home.assetsFolder
                    )
                ),
                userDefined: [:],
                year: currentYear
            )

        return .init(
            template: source.contents.pages.main.home.template ?? "pages.home",
            context: context,
            destination: destinationUrl.appendingPathComponent(
                "index.html"
            )
        )
    }

    func notFound() -> Renderable<Output.HTML<Void>> {
        let page = source.contents.pages.main.notFound
        return .init(
            template: page.template ?? "pages.404",
            context: .init(
                site: getContext(),
                page: .init(
                    metadata: metadata(for: page),
                    context: (),
                    content: render(
                        markdown: page.markdown,
                        folder: page.assetsFolder
                    )
                ),
                userDefined: [:],
                year: currentYear
            ),
            destination: destinationUrl
                .appendingPathComponent("404.html")
        )
    }

    
    

    
    
    
    //    func postListPages() -> [PostListHTMLPageState] {
    //        let postsPage = content.blog.post.home
    //        let pageLimit = content.config.blog.posts.page.limit
    //        let pages = content.blog.post.sortedContents.chunks(ofCount: pageLimit)
    //
    //        func replace(
    //            _ number: Int,
    //            _ value: String
    //        ) -> String {
    //            value.replacingOccurrences(
    //                of: "{{number}}",
    //                with: String(number)
    //            )
    //        }
    //
    //        var result: [PostListHTMLPageState] = []
    //        for (index, posts) in pages.enumerated() {
    //            let pageNumber = index + 1
    //
    //            let title = replace(pageNumber, postsPage.title)
    //            let description = replace(pageNumber, postsPage.description)
    //            let slug = replace(pageNumber, postsPage.slug)
    //
    //            let state: PostListHTMLPageState = .init(
    //                site: siteState(
    //                    for: content.config
    //                ),
    //                page: .init(
    //                    slug: slug,
    //                    metadata: .init(
    //                        permalink: permalink(slug),
    //                        title: title,
    //                        description: description,
    //                        imageUrl: assetUrl(
    //                            for: postsPage.coverImage,
    //                            folder: Content.Page.folder
    //                        )
    //                    ),
    //                    context: .init(
    //                        posts: posts.map {
    //                            postState(
    //                                for: $0,
    //                                authors: content.blog.author.contentsBy(
    //                                    slugs: $0.authorSlugs
    //                                ),
    //                                tags: content.blog.tag.contentsBy(
    //                                    slugs: $0.tagSlugs
    //                                )
    //                            )
    //                        },
    //                        pagination: (1...pages.count)
    //                            .map {
    //                                .init(
    //                                    number: $0,
    //                                    total: pages.count,
    //                                    slug: replace($0, postsPage.slug),
    //                                    permalink: permalink(
    //                                        replace($0, postsPage.slug)
    //                                    ),
    //                                    isCurrent: pageNumber == $0
    //                                )
    //                            }
    //                    ),
    //                    content: render(
    //                        markdown: postsPage.markdown,
    //                        folder: Content.Page.folder
    //                    )
    //                ),
    //                userDefined: content.config.site.userDefined
    //                    + postsPage.userDefined,
    //                year: currentYear,
    //                template: postsPage.template ?? "pages.blog.posts"
    //            )
    //
    //            result.append(state)
    //        }
    //
    //        return result
    //    }
    
    // MARK: - blog
    
    func blogHome() -> Renderable<Output.HTML<Context.Blog.Home>>? {
        guard let content = source.contents.pages.blog.home else {
            return nil
        }

        return .init(
            template: content.template ?? "pages.blog.home",
            context: .init(
                site: getContext(),
                page: .init(
                    metadata: metadata(for: content),
                    context: .init(
                        featured: [],
                        posts: [],
                        authors: [],
                        tags: []
                    ),
                    content: render(
                        markdown: content.markdown,
                        folder: content.assetsFolder
                    )
                ),
                userDefined: [:],
                year: currentYear
            ),
            destination: destinationUrl
                .appendingPathComponent(content.slug)
                .appendingPathComponent("index.html")
        )
    }
    
    
    // MARK: - authors
    
    func authorList() -> Renderable<Output.HTML<Context.Blog.Author.List>>? {
        guard let authors = source.contents.pages.blog.authors else {
            return nil
        }
        return .init(
            template: authors.template ?? "pages.blog.authors",
            context: .init(
                site: getContext(),
                page: .init(
                    metadata: metadata(for: authors),
                    context: .init(
                        authors: content.blog.sortedAuthors().map {
                            $0.context(site: self)
                        }
                    ),
                    content: render(
                        markdown: authors.markdown,
                        folder: authors.assetsFolder
                    )
                ),
                userDefined: [:],
                year: currentYear
            ),
            destination: destinationUrl
                .appendingPathComponent(authors.slug)
                .appendingPathComponent("index.html")
        )
    }
    
    func authorDetails() -> [Renderable<Output.HTML<Context.Blog.Author.Detail>>] {
        content.blog.authors.map { author in
            return .init(
                template: author.content.template ?? "pages.single.author",
                context: .init(
                    site: getContext(),
                    page: .init(
                        metadata: metadata(for: author.content),
                        context: .init(
                            author: author.context(site: self),
                            posts: author.posts.map { $0.context(site: self) }
                        ),
                        content: render(
                            markdown: author.content.markdown,
                            folder: author.content.assetsFolder
                        )
                    ),
                    userDefined: [:],
                    year: currentYear
                ),
                destination: destinationUrl
                    .appendingPathComponent(author.content.slug)
                    .appendingPathComponent("index.html")
            )
        }
    }
    
    // MARK: - tags
    
    
    func tagList() -> Renderable<Output.HTML<Context.Blog.Tag.List>>? {
        guard let tags = source.contents.pages.blog.tags else {
            return nil
        }
        return .init(
            template: tags.template ?? "pages.blog.tags",
            context: .init(
                site: getContext(),
                page: .init(
                    metadata: metadata(for: tags),
                    context: .init(
                        tags: content.blog.sortedTags().map {
                            $0.context(site: self)
                        }
                    ),
                    content: render(
                        markdown: tags.markdown,
                        folder: tags.assetsFolder
                    )
                ),
                userDefined: [:],
                year: currentYear
            ),
            destination: destinationUrl
                .appendingPathComponent(tags.slug)
                .appendingPathComponent("index.html")
        )
    }
    
    
    func tagDetails() -> [Renderable<Output.HTML<Context.Blog.Tag.Detail>>] {
        content.blog.tags.map { tag in
            return .init(
                template: tag.content.template ?? "pages.single.tag",
                context: .init(
                    site: getContext(),
                    page: .init(
                        metadata: metadata(for: tag.content),
                        context: .init(
                            tag: tag.context(site: self),
                            posts: tag.posts.map { $0.context(site: self) }
                        ),
                        content: render(
                            markdown: tag.content.markdown,
                            folder: tag.content.assetsFolder
                        )
                    ),
                    userDefined: [:],
                    year: currentYear
                ),
                destination: destinationUrl
                    .appendingPathComponent(tag.content.slug)
                    .appendingPathComponent("index.html")
            )
        }
    }
    
    
    //
    //    func nextPost(for slug: String) -> PostState? {
    //        let posts = content.blog.post.sortedContents
    //
    //        if let index = posts.firstIndex(where: { $0.slug == slug }) {
    //            if index > 0 {
    //                let post = posts[index - 1]
    //                return postState(
    //                    for: post,
    //                    authors: content.blog.author.contentsBy(
    //                        slugs: post.authorSlugs
    //                    ),
    //                    tags: content.blog.tag.contentsBy(
    //                        slugs: post.tagSlugs
    //                    )
    //                )
    //            }
    //        }
    //        return nil
    //    }
    //
    //    func prevPost(for slug: String) -> PostState? {
    //        let posts = content.blog.post.sortedContents
    //
    //        if let index = posts.firstIndex(where: { $0.slug == slug }) {
    //            if index < posts.count - 1 {
    //                let post = posts[index + 1]
    //                return postState(
    //                    for: post,
    //                    authors: content.blog.author.contentsBy(
    //                        slugs: post.authorSlugs
    //                    ),
    //                    tags: content.blog.tag.contentsBy(
    //                        slugs: post.tagSlugs
    //                    )
    //                )
    //            }
    //        }
    //        return nil
    //    }
    //
    //    func relatedPosts(for slug: String) -> [PostState] {
    //        var result: [PostState] = []
    //
    //        let posts = content.blog.post.sortedContents
    //        if let index = posts.firstIndex(where: { $0.slug == slug }) {
    //            let post = posts[index]
    //            for tagSlug in post.tagSlugs {
    //                result += content.blog.post.contentsBy(tagSlug: tagSlug)
    //                    .filter { $0.slug != slug }
    //                    .map {
    //                        postState(
    //                            for: $0,
    //                            authors: content.blog.author.contentsBy(
    //                                slugs: $0.authorSlugs
    //                            ),
    //                            tags: content.blog.tag.contentsBy(
    //                                slugs: $0.tagSlugs
    //                            )
    //                        )
    //                    }
    //            }
    //        }
    //        return Array(result.shuffled().prefix(5))
    //    }
    //
    //    func moreByPosts(for slug: String) -> [PostState] {
    //        var result: [PostState] = []
    //
    //        let posts = content.blog.post.sortedContents
    //        if let index = posts.firstIndex(where: { $0.slug == slug }) {
    //            let post = posts[index]
    //            for authorSlug in post.authorSlugs {
    //                result += content.blog.post.contentsBy(authorSlug: authorSlug)
    //                    .filter { $0.slug != slug }
    //                    .map {
    //                        postState(
    //                            for: $0,
    //                            authors: content.blog.author.contentsBy(
    //                                slugs: $0.authorSlugs
    //                            ),
    //                            tags: content.blog.tag.contentsBy(
    //                                slugs: $0.tagSlugs
    //                            )
    //                        )
    //                    }
    //            }
    //        }
    //        return Array(result.shuffled().prefix(5))
    //    }
    //
    //    func postDetails() -> [PostDetailHTMLPageState] {
    //        content.blog.post.contents.map {
    //            .init(
    //                site: siteState(for: content.config),
    //                page: .init(
    //                    slug: $0.slug,
    //                    metadata: metadata(for: $0),
    //                    context: .init(
    //                        post: postState(
    //                            for: $0,
    //                            authors: content.blog.author.contentsBy(
    //                                slugs: $0.authorSlugs
    //                            ),
    //                            tags: content.blog.tag.contentsBy(
    //                                slugs: $0.tagSlugs
    //                            )
    //                        ),
    //                        related: relatedPosts(for: $0.slug),
    //                        moreByAuthor: moreByPosts(for: $0.slug),
    //                        next: nextPost(for: $0.slug),
    //                        prev: prevPost(for: $0.slug)
    //                    ),
    //                    content: render(
    //                        markdown: $0.markdown,
    //                        folder: Content.Post.folder
    //                    )
    //                ),
    //                userDefined: content.config.site.userDefined + $0.userDefined,
    //                year: currentYear,
    //                template: $0.template ?? "pages.single.post"
    //            )
    //        }
    //    }
    //
    //    func pages() -> [PageDetailHTMLPageState] {
    //        content.custom.pages.map {
    //            .init(
    //                site: siteState(for: content.config),
    //                page: .init(
    //                    slug: $0.slug,
    //                    metadata: metadata(for: $0),
    //                    context: .init(
    //                        permalink: permalink($0.slug),
    //                        title: $0.title,
    //                        description: $0.description,
    //                        figure: figureState(
    //                            for: $0.coverImage,
    //                            folder: Content.Page.folder
    //                        ),
    //                        userDefined: $0.userDefined
    //                    ),
    //                    content: render(
    //                        markdown: $0.markdown,
    //                        folder: Content.Page.folder
    //                    )
    //                ),
    //                userDefined: content.config.site.userDefined + $0.userDefined,
    //                year: currentYear,
    //                template: $0.template ?? "pages.single.page"
    //            )
    //        }
    //    }
    
    func customPages() -> [Renderable<Output.HTML<Context.Pages.Detail>>] {
        source.contents.pages.custom.map { content in
            return .init(
                template: content.template ?? "pages.single.page",
                context: .init(
                    site: getContext(),
                    page: .init(
                        metadata: metadata(for: content),
                        // TODO: use site content
                        context: .init(
                            page: .init(
                                permalink: permalink(content.slug),
                                title: content.title,
                                description: content.description,
                                figure: nil,
                                userDefined: [:]
                            )
                        ),
                        content: render(
                            markdown: content.markdown,
                            folder: content.assetsFolder
                        )
                    ),
                    userDefined: [:],
                    year: currentYear
                ),
                destination: destinationUrl
                    .appendingPathComponent(content.slug)
                    .appendingPathComponent("index.html")
            )
        }
    }
    
    

    // MARK: - rss

    func rss() -> Renderable<Output.RSS> {
        let items: [Output.RSS.Item] = source.contents.blog.posts.map {
            .init(
                permalink: permalink($0.slug),
                title: $0.title,
                description: $0.description,
                publicationDate: rssDateFormatter.string(
                    from: .init()
                )
            )
        }

        let publicationDate =
            items.first?.publicationDate
            ?? rssDateFormatter.string(from: .init())

        let context = Output.RSS(
            title: source.config.site.title,
            description: source.config.site.description,
            baseUrl: source.config.site.baseUrl,
            language: source.config.site.language,
            lastBuildDate: rssDateFormatter.string(from: .init()),
            publicationDate: publicationDate,
            items: items
        )

        return .init(
            template: "rss",
            context: context,
            destination: destinationUrl.appendingPathComponent(
                "rss.xml"
            )
        )
    }

    // MARK: - sitemap

    func sitemap() -> Renderable<Output.Sitemap> {
        let context = Output.Sitemap(
            urls: source.contents.all()
                .map { content in
                    .init(
                        location: permalink(content.slug),
                        lastModification: sitemapDateFormatter.string(
                            from: content.lastModification
                        )
                    )
                }
        )
        return .init(
            template: "sitemap",
            context: context,
            destination: destinationUrl.appendingPathComponent(
                "sitemap.xml"
            )
        )
    }
}
