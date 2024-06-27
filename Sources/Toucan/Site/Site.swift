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
        
        
        let posts: [Content.Blog.Post] = source.materials.blog.posts.map {
            .init(
                content: $0,
                config: source.config,
                dateFormatter: DateFormatters.baseFormatter
            )
        }

        self.content = .init(
            blog: .init(
                posts: posts,
                authors: source.materials.blog.authors
                    .map { author in
                            .init(
                                content: author,
                                posts: posts.filter {
                                    $0.authors.contains(author.slug)
                                }
                            )
                    },
                tags: source.materials.blog.tags
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
        for content: SourceMaterial
    ) -> Context.Metadata {
        .init(
            slug: content.slug,
            permalink: permalink(content.slug),
            title: content.title,
            description: content.description,
            imageUrl: content.imageUrl().map { permalink($0) }
        )
    }
    
    func render(
        content: SourceMaterial
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
    
    func getOutputHTMLContext<T>(
        material: SourceMaterial,
        context: T
    ) -> Output.HTML<T> {
        let renderer = MarkdownToHTMLRenderer(
            delegate: HTMLRendererDelegate(
                site: self,
                content: material
            )
        )
        
        return .init(
            site: .init(
                baseUrl: source.config.site.baseUrl,
                title: source.config.site.title,
                description: source.config.site.description,
                language: source.config.site.language
            ),
            page: .init(
                metadata: .init(
                    slug: material.slug,
                    permalink: permalink(material.slug),
                    title: material.title,
                    description: material.description,
                    imageUrl: material.imageUrl().map { permalink($0) }
                ),
                css: material.cssUrls(),
                js: material.jsUrls(),
                data: material.data,
                context: context,
                content: renderer.render(
                    markdown: material.markdown
                )
            ),
            userDefined: source.config.site.userDefined
                .recursivelyMerged(with: material.userDefined),
            year: currentYear
        )
    }
    
    func home() -> Renderable<Output.HTML<Context.Main.Home>> {
        let material = source.materials.pages.main.home
        let context = getOutputHTMLContext(
            material: material,
            context: Context.Main.Home(
                featured: [],
                posts: [],
                authors: [],
                tags: [],
                pages: []
            )
        )
        return .init(
            template: material.template,
            context: context,
            destination: destinationUrl
                .appendingPathComponent(Toucan.Files.index)
        )
    }
    
    func notFound() -> Renderable<Output.HTML<Void>> {
        let material = source.materials.pages.main.notFound
        let context = getOutputHTMLContext(
            material: material,
            context: ()
        )
        return .init(
            template: material.template,
            context: context,
            destination: destinationUrl
                .appendingPathComponent(Toucan.Files.notFound)
        )
    }
    
    // MARK: - blog
    
    func blogHome() -> Renderable<Output.HTML<Context.Blog.Home>>? {
        guard let material = source.materials.pages.blog.home else {
            return nil
        }
        let context = getOutputHTMLContext(
            material: material,
            context: Context.Blog.Home(
                featured: [],
                posts: [],
                authors: [],
                tags: []
            )
        )
        return .init(
            template: material.template,
            context: context,
            destination: destinationUrl
                .appendingPathComponent(material.slug)
                .appendingPathComponent(Toucan.Files.index)
        )
    }
    
    
    // MARK: - authors
    
    func authorList() -> Renderable<Output.HTML<Context.Blog.Author.List>>? {
        guard let material = source.materials.pages.blog.authors else {
            return nil
        }
        let context = getOutputHTMLContext(
            material: material,
            context: Context.Blog.Author.List(
                authors: self.content.blog.sortedAuthors().map {
                    $0.context(site: self)
                }
            )
        )
        return .init(
            template: material.template,
            context: context,
            destination: destinationUrl
                .appendingPathComponent(material.slug)
                .appendingPathComponent(Toucan.Files.index)
        )
    }
    
    func authorDetails() -> [Renderable<Output.HTML<Context.Blog.Author.Detail>>] {
        content.blog.authors.map { author in
            let material = author.content
            let context = getOutputHTMLContext(
                material: material,
                context: Context.Blog.Author.Detail(
                    author: author.context(site: self),
                    posts: author.posts.map { $0.context(site: self) }
                )
            )
            return .init(
                template: material.template,
                context: context,
                destination: destinationUrl
                    .appendingPathComponent(material.slug)
                    .appendingPathComponent(Toucan.Files.index)
            )
        }
    }
    
    // MARK: - tags
    
    func tagList() -> Renderable<Output.HTML<Context.Blog.Tag.List>>? {
        guard let material = source.materials.pages.blog.tags else {
            return nil
        }
        let context = getOutputHTMLContext(
            material: material,
            context: Context.Blog.Tag.List(
                tags: self.content.blog.sortedTags().map {
                    $0.context(site: self)
                }
            )
        )
        return .init(
            template: material.template,
            context: context,
            destination: destinationUrl
                .appendingPathComponent(material.slug)
                .appendingPathComponent(Toucan.Files.index)
        )
    }
    
    
    func tagDetails() -> [Renderable<Output.HTML<Context.Blog.Tag.Detail>>] {
        content.blog.tags.map { tag in
            let material = tag.content
            let context = getOutputHTMLContext(
                material: material,
                context: Context.Blog.Tag.Detail(
                    tag: tag.context(site: self),
                    posts: tag.posts.map { $0.context(site: self) }
                )
            )
            return .init(
                template: material.template,
                context: context,
                destination: destinationUrl
                    .appendingPathComponent(material.slug)
                    .appendingPathComponent(Toucan.Files.index)
            )
        }
    }
    
    // MARK: - post
    
    func postListPaginated(
    ) -> [Renderable<Output.HTML<Context.Blog.Post.List>>] {
        guard let posts = source.materials.pages.blog.posts else {
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

            let material = posts.updated(
                title: title,
                description: description,
                slug: slug
            )
            let context = getOutputHTMLContext(
                material: material,
                context: Context.Blog.Post.List(
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
                )
            )

            let r = Renderable<Output.HTML<Context.Blog.Post.List>>(
                template: material.template,
                context: context,
                destination: destinationUrl
                    .appendingPathComponent(slug)
                    .appendingPathComponent(Toucan.Files.index)
            )
            
            result.append(r)
        }
        return result
    }
    
    func postDetails() -> [Renderable<Output.HTML<Context.Blog.Post.Detail>>] {
        content.blog.posts.map { post in
            let material = post.content
            let context = getOutputHTMLContext(
                material: material,
                context: Context.Blog.Post.Detail(
                    post: post.context(site: self),
                    related: [],
                    moreByAuthor: [],
                    next: nil,
                    prev: nil
                )
            )
            return .init(
                template: material.template,
                context: context,
                destination: destinationUrl
                    .appendingPathComponent(material.slug)
                    .appendingPathComponent(Toucan.Files.index)
            )
        }
    }
    
    
    // MARK: - custom
    
    func customPages() -> [Renderable<Output.HTML<Context.Pages.Detail>>] {
        source.materials.pages.custom.map { content in
            let material = content
            let context = getOutputHTMLContext(
                material: material,
                context: Context.Pages.Detail(
                    page: .init(
                        slug: content.slug,
                        permalink: permalink(content.slug),
                        title: content.title,
                        description: content.description,
                        imageUrl: content.imageUrl(),
                        userDefined: [:]
                    )
                )
            )
            
            return .init(
                template: material.template,
                context: context,
                destination: destinationUrl
                    .appendingPathComponent(material.slug)
                    .appendingPathComponent(Toucan.Files.index)
            )
        }
    }
    
    
    
    
    // MARK: - docs
    
    func docsHome() -> Renderable<Output.HTML<Context.Docs.Home>>? {
        guard let material = source.materials.pages.docs.home else {
            return nil
        }
        let context = getOutputHTMLContext(
            material: material,
            context: Context.Docs.Home(
                categories: source.materials.docs.categories.map {
                    .init(title: $0.title)
                },
                guides: source.materials.docs.guides.map {
                    .init(title: $0.title)
                }
            )
        )

        return .init(
            template: material.template,
            context: context,
            destination: destinationUrl
                .appendingPathComponent(material.slug)
                .appendingPathComponent(Toucan.Files.index)
        )
    }
    
    func docsCategoryList(
    ) -> Renderable<Output.HTML<Context.Docs.Category.List>>? {
        guard let material = source.materials.pages.docs.categories else {
            return nil
        }
        let context = getOutputHTMLContext(
            material: material,
            context: Context.Docs.Category.List(
                categories: source.materials.docs.categories.map {
                    .init(title: $0.title)
                }
            )
        )
        return .init(
            template: material.template,
            context: context,
            destination: destinationUrl
                .appendingPathComponent(material.slug)
                .appendingPathComponent(Toucan.Files.index)
        )
    }
    
    func docsCategoryDetails(
        
    ) -> [Renderable<Output.HTML<Context.Docs.Category>>] {
        source.materials.docs.categories.map { item in
            let material = item
            let context = getOutputHTMLContext(
                material: material,
                context: Context.Docs.Category(
                    title: item.title
                )
            )
            
            return .init(
                template: material.template,
                context: context,
                destination: destinationUrl
                    .appendingPathComponent(material.slug)
                    .appendingPathComponent(Toucan.Files.index)
            )
        }
    }
    
    // MARK: - guides
    
    func docsGuideList(
    ) -> Renderable<Output.HTML<Context.Docs.Guide.List>>? {
        guard let material = source.materials.pages.docs.guides else {
            return nil
        }
        let context = getOutputHTMLContext(
            material: material,
            context: Context.Docs.Guide.List(
                guides: source.materials.docs.guides.map {
                    .init(title: $0.title)
                }
            )
        )
        return .init(
            template: material.template,
            context: context,
            destination: destinationUrl
                .appendingPathComponent(material.slug)
                .appendingPathComponent(Toucan.Files.index)
        )
    }
    
    func docsGuideDetails(
    ) -> [Renderable<Output.HTML<Context.Docs.Guide>>] {
        source.materials.docs.guides.map { item in
            let material = item
            let context = getOutputHTMLContext(
                material: material,
                context: Context.Docs.Guide(
                    title: item.title
                )
            )
            return .init(
                template: material.template,
                context: context,
                destination: destinationUrl
                    .appendingPathComponent(material.slug)
                    .appendingPathComponent(Toucan.Files.index)
            )
        }
    }
    
    // MARK: - rss
    
    func rss() -> Renderable<Output.RSS> {
        let items: [Output.RSS.Item] = source.materials.blog.posts.map {
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
            destination: destinationUrl
                .appendingPathComponent(Toucan.Files.rss)
        )
    }
    
    
    // MARK: - sitemap
    
    func sitemap() -> Renderable<Output.Sitemap> {
        let context = Output.Sitemap(
            urls: source.materials.all()
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
            destination: destinationUrl
                .appendingPathComponent(Toucan.Files.sitemap)
        )
    }
}
