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
    
    func metadata(
        for content: Source.Content
    ) -> Context.Metadata {
        .init(
            slug: content.slug,
            permalink: permalink(content.slug),
            title: content.title,
            description: content.description,
            imageUrl: source.assets.url(
                for: content.image,
                folder: content.assetsFolder,
                permalink: permalink(_:)
            )
        )
    }
    
    func render(
        content: Source.Content
    ) -> String {
        let renderer = MarkdownToHTMLRenderer(
            delegate: HTMLRendererDelegate(
                site: self,
                content: content
            )
        )
        return renderer.render(markdown: content.markdown)
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
    
    // MARK: - main
    
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
                        content: source.contents.pages.main.home
                    )
                ),
                userDefined: [:],
                year: currentYear
            )
        
        return .init(
            template: source.contents.pages.main.home.template ?? "main.home",
            context: context,
            destination: destinationUrl.appendingPathComponent(
                "index.html"
            )
        )
    }
    
    func notFound() -> Renderable<Output.HTML<Void>> {
        let page = source.contents.pages.main.notFound
        return .init(
            template: page.template ?? "main.404",
            context: .init(
                site: getContext(),
                page: .init(
                    metadata: metadata(for: page),
                    context: (),
                    content: render(content: page)
                ),
                userDefined: [:],
                year: currentYear
            ),
            destination: destinationUrl
                .appendingPathComponent("404.html")
        )
    }
    
    // MARK: - blog
    
    func blogHome() -> Renderable<Output.HTML<Context.Blog.Home>>? {
        guard let content = source.contents.pages.blog.home else {
            return nil
        }
        
        return .init(
            template: content.template ?? "blog.home",
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
                        content: content
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
            template: authors.template ?? "blog.authors",
            context: .init(
                site: getContext(),
                page: .init(
                    metadata: metadata(for: authors),
                    context: .init(
                        authors: content.blog.sortedAuthors().map {
                            $0.context(site: self)
                        }
                    ),
                    content: render(content: authors)
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
                template: author.content.template ?? "blog.single.author",
                context: .init(
                    site: getContext(),
                    page: .init(
                        metadata: metadata(for: author.content),
                        context: .init(
                            author: author.context(site: self),
                            posts: author.posts.map { $0.context(site: self) }
                        ),
                        content: render(content: author.content)
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
            template: tags.template ?? "blog.tags",
            context: .init(
                site: getContext(),
                page: .init(
                    metadata: metadata(for: tags),
                    context: .init(
                        tags: content.blog.sortedTags().map {
                            $0.context(site: self)
                        }
                    ),
                    content: render(content: tags)
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
                template: tag.content.template ?? "blog.single.tag",
                context: .init(
                    site: getContext(),
                    page: .init(
                        metadata: metadata(for: tag.content),
                        context: .init(
                            tag: tag.context(site: self),
                            posts: tag.posts.map { $0.context(site: self) }
                        ),
                        content: render(content: tag.content)
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
    
    // MARK: - post
    
    func postListPaginated(
    ) -> [Renderable<Output.HTML<Context.Blog.Post.List>>] {
        guard let posts = source.contents.pages.blog.posts else {
            return []
        }

        let pageLimit = 10 // TODO: add config
        let pages = content.blog.sortedPosts().chunks(ofCount: pageLimit)
        
        func replace(
            _ number: Int,
            _ value: String
        ) -> String {
            value.replacingOccurrences(
                of: "{{number}}",
                with: String(number)
            )
        }

        var result: [Renderable<Output.HTML<Context.Blog.Post.List>>] = []
        for (index, postsChunk) in pages.enumerated() {
            let pageNumber = index + 1
            
            let title = replace(pageNumber, posts.title)
            let description = replace(pageNumber, posts.description)
            let slug = replace(pageNumber, posts.slug)
            
            let r = Renderable<Output.HTML<Context.Blog.Post.List>>(
                    template: posts.template ?? "blog.posts",
                    context: .init(
                        site: getContext(),
                        page: .init(
                            metadata: .init(
                                slug: slug,
                                permalink: permalink(slug),
                                title: title,
                                description: description,
                                imageUrl: posts.image
                            ),
                            context: .init(
                                posts: postsChunk.map { $0.context(site: self) },
                                pagination: (1...pages.count)
                                    .map {
                                        .init(
                                            number: $0,
                                            total: pages.count,
                                            slug: replace($0, posts.slug),
                                            permalink: permalink(
                                                replace($0, posts.slug)
                                            ),
                                            isCurrent: pageNumber == $0
                                        )
                                    }
                            ),
                            content: render(content: posts)
                        ),
                        userDefined: [:],
                        year: currentYear
                    ),
                    destination: destinationUrl
                        .appendingPathComponent(slug)
                        .appendingPathComponent("index.html")
                )
            
            result.append(r)
        }
        return result
    }
    
    func postDetails() -> [Renderable<Output.HTML<Context.Blog.Post.Detail>>] {
        content.blog.posts.map { post in
            return .init(
                template: post.content.template ?? "blog.single.post",
                context: .init(
                    site: getContext(),
                    page: .init(
                        metadata: metadata(for: post.content),
                        context: .init(
                            post: post.context(site: self),
                            related: [],
                            moreByAuthor: [],
                            next: nil,
                            prev: nil
                        ),
                        content: render(content: post.content)
                    ),
                    userDefined: [:],
                    year: currentYear
                ),
                destination: destinationUrl
                    .appendingPathComponent(post.content.slug)
                    .appendingPathComponent("index.html")
            )
        }
    }
    
    
    // MARK: - custom
    
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
                                slug: content.slug,
                                permalink: permalink(content.slug),
                                title: content.title,
                                description: content.description,
                                imageUrl: content.resolvedImageUrl(),
                                userDefined: [:]
                            )
                        ),
                        content: render(content: content)
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
    
    // MARK: - docs
    
    func docsHome() -> Renderable<Output.HTML<Context.Docs.Home>>? {
        guard let content = source.contents.pages.docs.home else {
            return nil
        }
        
        return .init(
            template: content.template ?? "docs.home",
            context: .init(
                site: getContext(),
                page: .init(
                    metadata: metadata(for: content),
                    context: .init(
                        categories: source.contents.docs.categories.map {
                            .init(title: $0.title)
                        },
                        guides: source.contents.docs.guides.map {
                            .init(title: $0.title)
                        }
                    ),
                    content: render(content: content)
                ),
                userDefined: [:],    // TODO: user defined
                year: currentYear
            ),
            destination: destinationUrl
                .appendingPathComponent(content.slug)
                .appendingPathComponent("index.html")
        )
    }
    
    func docsCategoryList(
    ) -> Renderable<Output.HTML<Context.Docs.Category.List>>? {
        guard let content = source.contents.pages.docs.categories else {
            return nil
        }
        
        return .init(
            template: content.template ?? "docs.categories",
            context: .init(
                site: getContext(),
                page: .init(
                    metadata: metadata(for: content),
                    context: .init(
                        categories: source.contents.docs.categories.map {
                            .init(title: $0.title)
                        }
                    ),
                    content: render(content: content)
                ),
                userDefined: [:],
                year: currentYear
            ),
            destination: destinationUrl
                .appendingPathComponent(content.slug)
                .appendingPathComponent("index.html")
        )
    }
    
    func docsCategoryDetails(
    ) -> [Renderable<Output.HTML<Context.Docs.Category>>] {
        source.contents.docs.categories.map { item in
            .init(
                template: item.template ?? "docs.single.category",
                context: .init(
                    site: getContext(),
                    page: .init(
                        metadata: metadata(for: item),
                        context: .init(title: item.title),
                        content: render(content: item)
                    ),
                    userDefined: [:],    // TODO: user defined
                    year: currentYear
                ),
                destination: destinationUrl
                    .appendingPathComponent(item.slug)
                    .appendingPathComponent("index.html")
            )
        }
    }
    
    // MARK: - guides
    
    func docsGuideList(
    ) -> Renderable<Output.HTML<Context.Docs.Guide.List>>? {
        guard let content = source.contents.pages.docs.guides else {
            return nil
        }
        
        return .init(
            template: content.template ?? "docs.guides",
            context: .init(
                site: getContext(),
                page: .init(
                    metadata: metadata(for: content),
                    context: .init(
                        guides: source.contents.docs.guides.map {
                            .init(title: $0.title)
                        }
                    ),
                    content: render(content: content)
                ),
                userDefined: [:],
                year: currentYear
            ),
            destination: destinationUrl
                .appendingPathComponent(content.slug)
                .appendingPathComponent("index.html")
        )
    }
    
    func docsGuideDetails(
    ) -> [Renderable<Output.HTML<Context.Docs.Guide>>] {
        source.contents.docs.guides.map { item in
            .init(
                template: item.template ?? "docs.single.guide",
                context: .init(
                    site: getContext(),
                    page: .init(
                        metadata: metadata(for: item),
                        context: .init(title: item.title),
                        content: render(content: item)
                    ),
                    userDefined: [:],    // TODO: user defined
                    year: currentYear
                ),
                destination: destinationUrl
                    .appendingPathComponent(item.slug)
                    .appendingPathComponent("index.html")
            )
        }
    }
}
