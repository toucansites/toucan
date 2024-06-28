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
    
    let contents: Site.Contents
    
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
        
        
        let posts: [Contents.Blog.Post] = source.materials.blog.posts.map {
            .init(
                material: $0,
                config: source.config,
                dateFormatter: DateFormatters.baseFormatter
            )
        }

        self.contents = .init(
            config: source.config,
            blog: .init(
                posts: posts,
                authors: source.materials.blog.authors
                    .map { author in
                            .init(
                                material: author,
                                posts: posts.filter {
                                    $0.authors.contains(author.slug)
                                }
                            )
                    },
                tags: source.materials.blog.tags
                    .map { tag in
                            .init(
                                material: tag,
                                posts: posts.filter {
                                    $0.tags.contains(tag.slug)
                                }
                            )
                    }
            ),
            docs: .init(
                categories: source.materials.docs.categories.map {
                    .init(material: $0)
                },
                guides: source.materials.docs.guides.map {
                    .init(material: $0, config: source.config)
                }
            ),
            pages: .init(
                custom: source.materials.pages.custom.map {
                    .init(material: $0)
                }
            )
        )
    }
    
    // MARK: - utilities

    func permalink(_ value: String) -> String {
        let components = value.split(separator: "/").map(String.init)
        if components.isEmpty {
            return contents.config.site.baseUrl
        }
        if components.last?.split(separator: ".").count ?? 0 > 1 {
            return contents.config.site.baseUrl + components.joined(separator: "/")
        }
        return contents.config.site.baseUrl + components.joined(separator: "/") + "/"
    }
    
    func metadata(
        for material: SourceMaterial
    ) -> Context.Metadata {
        .init(
            slug: material.slug,
            permalink: permalink(material.slug),
            title: material.title,
            description: material.description,
            imageUrl: material.imageUrl().map { permalink($0) }
        )
    }
    
    func render(
        material: SourceMaterial
    ) -> String {
        let renderer = MarkdownToHTMLRenderer(
            delegate: HTMLRendererDelegate(
                config: contents.config,
                material: material
            )
        )
        return renderer.render(markdown: material.markdown)
    }
    
    func readingTime(_ value: String) -> Int {
        value.split(separator: " ").count / 238
    }
    
    // MARK: - context helpers
    
    func getContext() -> Context.Site {
        .init(
            baseUrl: contents.config.site.baseUrl,
            title: contents.config.site.title,
            description: contents.config.site.description,
            language: contents.config.site.language
        )
    }
    
    // MARK: - main
    
    func getOutputHTMLContext<T>(
        material: SourceMaterial,
        context: T
    ) -> HTML<T> {
        let renderer = MarkdownToHTMLRenderer(
            delegate: HTMLRendererDelegate(
                config: contents.config,
                material: material
            )
        )
        
        return .init(
            site: .init(
                baseUrl: contents.config.site.baseUrl,
                title: contents.config.site.title,
                description: contents.config.site.description,
                language: contents.config.site.language
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
            userDefined: contents.config.site.userDefined
                .recursivelyMerged(with: material.userDefined),
            year: currentYear
        )
    }
    
    func home() -> Renderable<HTML<Context.Main.Home>> {
        let material = source.materials.pages.main.home
        let context = getOutputHTMLContext(
            material: material,
            context: Context.Main.Home(
                featured: contents.blog.featuredPosts().map { $0.context(site: self) },
                posts: contents.blog.latestPosts().map { $0.context(site: self) },
                authors: contents.blog.sortedAuthors().map { $0.context(site: self) },
                tags: contents.blog.sortedTags().map { $0.context(site: self) },
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
    
    func notFound() -> Renderable<HTML<Void>> {
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
    
    func blogHome() -> Renderable<HTML<Context.Blog.Home>>? {
        guard let material = source.materials.pages.blog.home else {
            return nil
        }
        let context = getOutputHTMLContext(
            material: material,
            context: Context.Blog.Home(
                featured: contents.blog.featuredPosts().map { $0.context(site: self) },
                posts: contents.blog.latestPosts().map { $0.context(site: self) },
                authors: contents.blog.sortedAuthors().map { $0.context(site: self) },
                tags: contents.blog.sortedTags().map { $0.context(site: self) }
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
    
    func authorList() -> Renderable<HTML<Context.Blog.Author.List>>? {
        guard let material = source.materials.pages.blog.authors else {
            return nil
        }
        let context = getOutputHTMLContext(
            material: material,
            context: Context.Blog.Author.List(
                authors: self.contents.blog.sortedAuthors().map {
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
    
    func authorDetails() -> [Renderable<HTML<Context.Blog.Author.Detail>>] {
        contents.blog.authors.map { author in
            let material = author.material
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
    
    func tagList() -> Renderable<HTML<Context.Blog.Tag.List>>? {
        guard let material = source.materials.pages.blog.tags else {
            return nil
        }
        let context = getOutputHTMLContext(
            material: material,
            context: Context.Blog.Tag.List(
                tags: self.contents.blog.sortedTags().map {
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
    
    
    func tagDetails() -> [Renderable<HTML<Context.Blog.Tag.Detail>>] {
        contents.blog.tags.map { tag in
            let material = tag.material
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
    ) -> [Renderable<HTML<Context.Blog.Post.List>>] {
        guard let posts = source.materials.pages.blog.posts else {
            return []
        }

        let pageLimit = 10 // TODO: add config
        let pages = contents.blog.sortedPosts().chunks(ofCount: pageLimit)
        
        func replace(
            _ number: Int,
            _ value: String
        ) -> String {
            value.replacingOccurrences(
                of: "{{number}}",
                with: String(number)
            )
        }

        var result: [Renderable<HTML<Context.Blog.Post.List>>] = []
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

            let r = Renderable<HTML<Context.Blog.Post.List>>(
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
    
    func postDetails() -> [Renderable<HTML<Context.Blog.Post.Detail>>] {
        contents.blog.posts.map { post in
            let material = post.material
            let context = getOutputHTMLContext(
                material: material,
                context: Context.Blog.Post.Detail(
                    post: post.context(site: self),
                    related: contents.blog.related(post: post).map { $0.context(site: self) },
                    moreByAuthor: contents.blog.more(post: post).map { $0.context(site: self) },
                    next: contents.blog.nextPost(post).map { $0.context(site: self) },
                    prev: contents.blog.prevPost(post).map { $0.context(site: self) }
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
    
    func customPages() -> [Renderable<HTML<Context.Pages.Detail>>] {
        contents.pages.custom.map { page in
            let material = page.material
            let context = getOutputHTMLContext(
                material: material,
                context: Context.Pages.Detail(
                    // TODO: use page content
                    page: .init(
                        slug: material.slug,
                        permalink: permalink(material.slug),
                        title: material.title,
                        description: material.description,
                        imageUrl: material.imageUrl(),
                        userDefined: [:] //TODO: !!!
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
    
    func docsHome() -> Renderable<HTML<Context.Docs.Home>>? {
        guard let material = source.materials.pages.docs.home else {
            return nil
        }
        let context = getOutputHTMLContext(
            material: material,
            context: Context.Docs.Home(
                categories: contents.docs.sortedCategories.map { $0.context(site: self) },
                guides: contents.docs.sortedGuides.map { $0.context(site: self) }
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
    ) -> Renderable<HTML<Context.Docs.Category.List>>? {
        guard let material = source.materials.pages.docs.categories else {
            return nil
        }
        let context = getOutputHTMLContext(
            material: material,
            context: Context.Docs.Category.List(
                categories: contents.docs.sortedCategories.map { $0.context(site: self) }
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
        
    ) -> [Renderable<HTML<Context.Docs.Category.Detail>>] {
        contents.docs.categories.map { item in
            let material = item.material
            let context = getOutputHTMLContext(
                material: material,
                context: Context.Docs.Category.Detail(
                    category: .init(
                        slug: "",
                        permalink: "",
                        title: "",
                        description: "",
                        imageUrl: nil,
                        date: "",
                        guides: [],
                        userDefined: [:]
                    ),
                    guides: []
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
    ) -> Renderable<HTML<Context.Docs.Guide.List>>? {
        guard let material = source.materials.pages.docs.guides else {
            return nil
        }
        let context = getOutputHTMLContext(
            material: material,
            context: Context.Docs.Guide.List(
                guides: contents.docs.sortedGuides.map { $0.context(site: self) }
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
    ) -> [Renderable<HTML<Context.Docs.Guide.Detail>>] {
        contents.docs.guides.map { item in
            let material = item.material
            let context = getOutputHTMLContext(
                material: material,
                context: Context.Docs.Guide.Detail(
                    categories: contents.docs.categories.map {
                        $0.context(site: self)
                    },
                    guide: item.context(
                        site: self
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
    
    // MARK: - rss
    
    func rss() -> Renderable<RSS> {
        let items: [RSS.Item] = contents.blog.sortedPosts().map { item in
            let material = item.material
            return .init(
                permalink: permalink(material.slug),
                title: material.title,
                description: material.description,
                publicationDate: rssDateFormatter.string(
                    from: item.published
                )
            )
        }
        
        let publicationDate =
        items.first?.publicationDate
        ?? rssDateFormatter.string(from: .init())
        
        let context = RSS(
            title: contents.config.site.title,
            description: contents.config.site.description,
            baseUrl: contents.config.site.baseUrl,
            language: contents.config.site.language,
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
    
    func sitemap() -> Renderable<Sitemap> {
        let context = Sitemap(
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
