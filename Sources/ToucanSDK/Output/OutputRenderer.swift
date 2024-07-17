//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 21/06/2024.
//

import Foundation

/// Responsible to build renderable files using the site context & templates.
struct OutputRenderer {

    public enum Files {
        static let index = "index.html"
        static let notFound = "404.html"
        static let rss = "rss.xml"
        static let feed = "feed.xml"
        static let sitemap = "sitemap.xml"
    }

    let site: Site

    let templatesUrl: URL
    let overridesUrl: URL
    let destinationUrl: URL

    let fileManager: FileManager = .default

    func render() throws {
        let renderer = try MustacheToHTMLRenderer(
            templatesUrl: templatesUrl,
            overridesUrl: overridesUrl
        )

        let home = home()
        let notFound = notFound()
        try render(renderer, home)
        try render(renderer, notFound)
        
        // render rss & sitemap
        let rss = rss()
        let sitemap = sitemap()
        
        try render(renderer, rss)
        try render(renderer, sitemap)
        if let feed = feed() {
            try render(renderer, feed)
        }
        
        // MARK: - blog
    
        if let renderable = blogHome() {
            try render(renderer, renderable)
        }
        if let renderable = blogAuthorList() {
            try render(renderer, renderable)
        }
        for renderable in blogAuthorDetails() {
            try render(renderer, renderable)
        }
        if let renderable = blogTagList() {
            try render(renderer, renderable)
        }
        for renderable in blogTagDetails() {
            try render(renderer, renderable)
        }
        for renderable in blogPostListPaginated() {
            try render(renderer, renderable)
        }
        for renderable in blogPostDetails() {
            try render(renderer, renderable)
        }
        
        // MARK: - docs
        
        if let docsHome = docsHome() {
            try render(renderer, docsHome)
        }
        if let docsCategoryList = docsCategoryList() {
            try render(renderer, docsCategoryList)
        }
        for renderable in docsCategoryDetails() {
            try render(renderer, renderable)
        }
        if let docsGuidList = docsGuideList() {
            try render(renderer, docsGuidList)
        }
        for renderable in docsGuideDetails() {
            try render(renderer, renderable)
        }
        
        // MARK: - custom pages
        
        if let customPagesHome = customPagesHome() {
            try render(renderer, customPagesHome)
        }
        for renderable in customPages() {
            try render(renderer, renderable)
        }
        
        // MARK: - redirects

        for renderable in redirects() {
            try render(renderer, renderable)
        }        
    }

    // MARK: -

    func render<T>(
        _ renderer: MustacheToHTMLRenderer,
        _ renderable: Renderable<T>
    ) throws {
        try fileManager.createParentFolderIfNeeded(
            for: renderable.destination
        )
        try renderer.render(
            template: renderable.template,
            with: renderable.context,
            to: renderable.destination
        )
    }
    
    // MARK: - pages
    
    func notFound() -> Renderable<HTML<Void>> {
        let material = site.source.materials.pages.main.notFound
        let context = site.getOutputHTMLContext(
            material: material,
            context: ()
        )
        return .init(
            template: material.template,
            context: context,
            destination: destinationUrl
                .appendingPathComponent(Files.notFound)
        )
    }
    
    func home() -> Renderable<HTML<Context.Main.HomePage>> {
        let material = site.source.materials.pages.main.home
        let context = site.getOutputHTMLContext(
            material: material,
            context: Context.Main.HomePage(
                featured: site.contents.blog.featuredPosts().map { $0.context(site: site) },
                posts: site.contents.blog.latestPosts().map { $0.context(site: site) },
                authors: site.contents.blog.authors.map { $0.context(site: site) },
                tags: site.contents.blog.tags.map { $0.context(site: site) },
                pages: site.contents.pages.custom.map { $0.context(site: site) },
                categories: site.contents.docs.categories.map { category in
                    category.context(
                        site: site,
                        guides: site.contents.docs.guides(category: category)
                    )
                }
            )
        )
        return .init(
            template: material.template,
            context: context,
            destination: destinationUrl
                .appendingPathComponent(Files.index)
        )
    }
    
    // MARK: - custom pages
    
    func customPagesHome() -> Renderable<HTML<Context.Pages.Home>>? {
        guard let material = site.source.materials.pages.custom.home else {
            return nil
        }
        let context = site.getOutputHTMLContext(
            material: material,
            context: Context.Pages.Home(
                pages: site.contents.pages.custom.map { $0.context(site: site) }
            )
        )

        return .init(
            template: material.template,
            context: context,
            destination: destinationUrl
                .appendingPathComponent(material.slug)
                .appendingPathComponent(Files.index)
        )
    }
    
    func customPages() -> [Renderable<HTML<Context.Pages.DetailPage>>] {
        site.contents.pages.custom.map { page in
            let material = page.material
            let context = site.getOutputHTMLContext(
                material: material,
                context: Context.Pages.DetailPage(
                    page: page.context(site: site)
                )
            )
            
            return .init(
                template: material.template,
                context: context,
                destination: destinationUrl
                    .appendingPathComponent(material.slug)
                    .appendingPathComponent(Files.index)
            )
        }
    }
    
    // MARK: - blog
    
    func blogHome() -> Renderable<HTML<Context.Blog.HomePage>>? {
        guard let material = site.source.materials.pages.blog.home else {
            return nil
        }
        let pageLimit = Int(site.source.config.contents.pagination.limit)
        let pages = site.contents.blog.posts.chunks(ofCount: pageLimit)
        var pagination: [Context.Pagination] = []
        if let posts = site.source.materials.pages.blog.posts {
            pagination = (1...pages.count)
                .map {
                    let slug = replacePaginationInfo(
                        current: $0,
                        total: pages.count,
                        in: posts.slug
                    )
                    return .init(
                        number: $0,
                        total: pages.count,
                        slug: slug,
                        permalink: site.permalink(slug),
                        isCurrent: false
                    )
                }
        }
        

        let context = site.getOutputHTMLContext(
            material: material,
            context: Context.Blog.HomePage(
                featured: site.contents.blog.featuredPosts().map { $0.context(site: site) },
                posts: site.contents.blog.latestPosts().map { $0.context(site: site) },
                authors: site.contents.blog.authors.map { $0.context(site: site) },
                tags: site.contents.blog.tags.map { $0.context(site: site) },
                pagination: pagination
            )
        )
        return .init(
            template: material.template,
            context: context,
            destination: destinationUrl
                .appendingPathComponent(material.slug)
                .appendingPathComponent(Files.index)
        )
    }
    
    
    // MARK: - authors
    
    func blogAuthorList() -> Renderable<HTML<Context.Blog.Author.ListPage>>? {
        guard let material = site.source.materials.pages.blog.authors else {
            return nil
        }
        let context = site.getOutputHTMLContext(
            material: material,
            context: Context.Blog.Author.ListPage(
                authors: site.contents.blog.authors.map {
                    $0.context(site: site)
                }
            )
        )
        return .init(
            template: material.template,
            context: context,
            destination: destinationUrl
                .appendingPathComponent(material.slug)
                .appendingPathComponent(Files.index)
        )
    }
    
    func blogAuthorDetails() -> [Renderable<HTML<Context.Blog.Author.DetailPage>>] {
        site.contents.blog.authors.map { author in
            let material = author.material
            let context = site.getOutputHTMLContext(
                material: material,
                context: Context.Blog.Author.DetailPage(
                    author: author.context(site: site),
                    posts: author.posts.map { $0.context(site: site) }
                )
            )
            return .init(
                template: material.template,
                context: context,
                destination: destinationUrl
                    .appendingPathComponent(material.slug)
                    .appendingPathComponent(Files.index)
            )
        }
    }
    
    // MARK: - tags
    
    func blogTagList() -> Renderable<HTML<Context.Blog.Tag.ListPage>>? {
        guard let material = site.source.materials.pages.blog.tags else {
            return nil
        }
        let context = site.getOutputHTMLContext(
            material: material,
            context: Context.Blog.Tag.ListPage(
                tags: site.contents.blog.tags.map {
                    $0.context(site: site)
                }
            )
        )
        return .init(
            template: material.template,
            context: context,
            destination: destinationUrl
                .appendingPathComponent(material.slug)
                .appendingPathComponent(Files.index)
        )
    }
    
    
    func blogTagDetails() -> [Renderable<HTML<Context.Blog.Tag.DetailPage>>] {
        site.contents.blog.tags.map { tag in
            let material = tag.material
            let context = site.getOutputHTMLContext(
                material: material,
                context: Context.Blog.Tag.DetailPage(
                    tag: tag.context(site: site),
                    posts: tag.posts.map { $0.context(site: site) }
                )
            )
            return .init(
                template: material.template,
                context: context,
                destination: destinationUrl
                    .appendingPathComponent(material.slug)
                    .appendingPathComponent(Files.index)
            )
        }
    }
    
    // MARK: - post
    
    func replacePaginationInfo(
        current: Int,
        total: Int,
        in value: String
    ) -> String {
        value.replacingOccurrences(
            of: "{{pages.current}}",
            with: String(current)
        )
        .replacingOccurrences(
            of: "{{pages.total}}",
            with: String(total)
        )
    }
    
    func blogPostListPaginated(
    ) -> [Renderable<HTML<Context.Blog.Post.ListPage>>] {
        guard let posts = site.source.materials.pages.blog.posts else {
            return []
        }

        let pageLimit = Int(site.source.config.contents.pagination.limit)
        let pages = site.contents.blog.posts.chunks(ofCount: pageLimit)

        var result: [Renderable<HTML<Context.Blog.Post.ListPage>>] = []
        for (index, postsChunk) in pages.enumerated() {
            let pageNumber = index + 1
            
            
            
            let title = replacePaginationInfo(
                current: pageNumber,
                total: pages.count,
                in: posts.title
            )
            let description = replacePaginationInfo(
                current: pageNumber,
                total: pages.count,
                in: posts.description
            )
            let slug = replacePaginationInfo(
                current: pageNumber,
                total: pages.count,
                in: posts.slug
            )
            
            var prev: String? = nil
            if index > 0 {
                prev = replacePaginationInfo(
                    current: pageNumber - 1,
                    total: pages.count,
                    in: posts.slug
                )
            }
            
            var next: String? = nil
            if index < pages.count - 1 {
                next = replacePaginationInfo(
                    current: pageNumber - 1,
                    total: pages.count,
                    in: posts.slug
                )
            }

            let material = posts.updated(
                title: title,
                description: description,
                markdown: replacePaginationInfo(
                    current: pageNumber,
                    total: pages.count,
                    in: posts.markdown
                ),
                slug: slug
            )
            let context = site.getOutputHTMLContext(
                material: material,
                context: Context.Blog.Post.ListPage(
                    posts: postsChunk.map { $0.context(site: site) },
                    pagination: (1...pages.count)
                        .map {
                            let slug = replacePaginationInfo(
                                current: $0,
                                total: pages.count,
                                in: posts.slug
                            )
                            return .init(
                                number: $0,
                                total: pages.count,
                                slug: slug,
                                permalink: site.permalink(slug),
                                isCurrent: pageNumber == $0
                            )
                        }
                ),
                prev: prev.map { site.permalink($0) },
                next: next.map { site.permalink($0) }
            )

            let r = Renderable<HTML<Context.Blog.Post.ListPage>>(
                template: material.template,
                context: context,
                destination: destinationUrl
                    .appendingPathComponent(slug)
                    .appendingPathComponent(Files.index)
            )
            
            result.append(r)
        }
        return result
    }
    
    func blogPostDetails() -> [Renderable<HTML<Context.Blog.Post.DetailPage>>] {
        site.contents.blog.posts.map { post in
            let material = post.material
            let context = site.getOutputHTMLContext(
                material: material,
                context: Context.Blog.Post.DetailPage(
                    post: post.context(site: site),
                    related: site.contents.blog.related(post: post).map { $0.context(site: site) },
                    moreByAuthor: site.contents.blog.more(post: post).map { $0.context(site: site) },
                    next: site.contents.blog.nextPost(post).map { $0.context(site: site) },
                    prev: site.contents.blog.prevPost(post).map { $0.context(site: site) }
                )
            )
            return .init(
                template: material.template,
                context: context,
                destination: destinationUrl
                    .appendingPathComponent(material.slug)
                    .appendingPathComponent(Files.index)
            )
        }
    }

    

    // MARK: - docs
    
    func docsHome() -> Renderable<HTML<Context.Docs.HomePage>>? {
        guard let material = site.source.materials.pages.docs.home else {
            return nil
        }
        let context = site.getOutputHTMLContext(
            material: material,
            context: Context.Docs.HomePage(
                categories: site.contents.docs.categories.map { category in
                    category.context(
                        site: site,
                        guides: site.contents.docs.guides(category: category)
                    )
                },
                guides: site.contents.docs.guides.map { $0.ref(site: site) }
            )
        )

        return .init(
            template: material.template,
            context: context,
            destination: destinationUrl
                .appendingPathComponent(material.slug)
                .appendingPathComponent(Files.index)
        )
    }
    
    func docsCategoryList(
    ) -> Renderable<HTML<Context.Docs.Category.ListPage>>? {
        guard let material = site.source.materials.pages.docs.categories else {
            return nil
        }
        let context = site.getOutputHTMLContext(
            material: material,
            context: Context.Docs.Category.ListPage(
                categories: site.contents.docs.categories.map { category in
                    category.context(
                        site: site,
                        guides: site.contents.docs.guides(category: category)
                    )
                }
            )
        )
        return .init(
            template: material.template,
            context: context,
            destination: destinationUrl
                .appendingPathComponent(material.slug)
                .appendingPathComponent(Files.index)
        )
    }
    
    func docsCategoryDetails(
    ) -> [Renderable<HTML<Context.Docs.Category.DetailPage>>] {
        site.contents.docs.categories.map { item in
            let material = item.material
            let context = site.getOutputHTMLContext(
                material: material,
                context: Context.Docs.Category.DetailPage(
                    categories: site.contents.docs.categories.map {
                        $0.context(
                            site: site,
                            guides: site.contents.docs.guides(category: $0)
                        )
                    },
                    category: item.context(
                        site: site,
                        guides: site.contents.docs.guides(
                            category: item
                        )
                    )
                )
            )
            
            return .init(
                template: material.template,
                context: context,
                destination: destinationUrl
                    .appendingPathComponent(material.slug)
                    .appendingPathComponent(Files.index)
            )
        }
    }
    
    // MARK: - guides
    
    func docsGuideList(
    ) -> Renderable<HTML<Context.Docs.Guide.ListPage>>? {
        guard let material = site.source.materials.pages.docs.guides else {
            return nil
        }
        let context = site.getOutputHTMLContext(
            material: material,
            context: Context.Docs.Guide.ListPage(
                categories: site.contents.docs.categories.map {
                    $0.context(
                        site: site,
                        guides: site.contents.docs.guides(category: $0)
                    )
                },
                guides: site.contents.docs.guides.map { $0.ref(site: site) }
            )
        )
        return .init(
            template: material.template,
            context: context,
            destination: destinationUrl
                .appendingPathComponent(material.slug)
                .appendingPathComponent(Files.index)
        )
    }
    
    func docsGuideDetails(
    ) -> [Renderable<HTML<Context.Docs.Guide.DetailPage>>] {
        site.contents.docs.guides.compactMap { guides in
            guard let category = site.contents.docs.category(for: guides) else {
                return nil
            }
            let material = guides.material
            let context = site.getOutputHTMLContext(
                material: material,
                context: Context.Docs.Guide.DetailPage(
                    categories: site.contents.docs.categories.map { category in
                        category.context(
                            site: site,
                            guides: site.contents.docs.guides(category: category)
                        )
                    },
                    guide: guides.context(
                        site: site,
                        category: category.ref(site: site),
                        prev: site.contents.docs.prev(guides)?.ref(site: site),
                        next: site.contents.docs.next(guides)?.ref(site: site)
                    )
                )
            )
            return .init(
                template: material.template,
                context: context,
                destination: destinationUrl
                    .appendingPathComponent(material.slug)
                    .appendingPathComponent(Files.index)
            )
        }
    }
    
    // MARK: - rss
    
    func rss() -> Renderable<RSS> {
        let items: [RSS.Item] = site.contents.blog.posts.map { item in
            let material = item.material
            return .init(
                permalink: site.permalink(material.slug),
                title: material.title,
                description: material.description,
                publicationDate: site.rssDateFormatter.string(
                    from: item.material.publication
                )
            )
        }
        
        let publicationDate = items.first?.publicationDate ?? site.rssDateFormatter.string(from: .init())
        
        let context = RSS(
            title: site.contents.config.site.title,
            description: site.contents.config.site.description,
            baseUrl: site.contents.config.site.baseUrl,
            language: site.contents.config.site.language,
            lastBuildDate: site.rssDateFormatter.string(from: .init()),
            publicationDate: publicationDate,
            items: items
        )
        
        return .init(
            template: "rss",
            context: context,
            destination: destinationUrl
                .appendingPathComponent(Files.rss)
        )
    }
    
    func feed() -> Renderable<Feed>? {
        let userDefined = site.contents.config.userDefined
        guard userDefined.value("podcast.feed", as: Bool.self) ?? false else {
            return nil
        }
        let items: [Feed.Item] = site.contents.blog.posts.map { item in
            let material = item.material
            return .init(
                permalink: site.permalink(material.slug),
                title: material.title,
                description: material.description,
                publicationDate: site.rssDateFormatter.string(
                    from: item.material.publication
                )
            )
        }
        
        let publicationDate = items.first?.publicationDate ?? site.rssDateFormatter.string(from: .init())
        
        let context = Feed(
            title: site.contents.config.site.title,
            description: site.contents.config.site.description,
            baseUrl: site.contents.config.site.baseUrl,
            language: site.contents.config.site.language,
            lastBuildDate: site.rssDateFormatter.string(from: .init()),
            publicationDate: publicationDate,
            items: items
        )
        
        return .init(
            template: "feed",
            context: context,
            destination: destinationUrl
                .appendingPathComponent("podcast")
                .appendingPathComponent(Files.feed)
        )
    }
    
    
    // MARK: - sitemap
    
    func sitemap() -> Renderable<Sitemap> {
        let context = Sitemap(
            urls: site.source.materials.all()
                .map { content in
                        .init(
                            location: site.permalink(content.slug),
                            lastModification: site.sitemapDateFormatter.string(
                                from: content.lastModification
                            )
                        )
                }
        )
        return .init(
            template: "sitemap",
            context: context,
            destination: destinationUrl
                .appendingPathComponent(Files.sitemap)
        )
    }
    
    // MARK: - redirects
    
    func redirects() -> [Renderable<Redirect>] {
        site.source.materials.all().map { material in
            material.redirects.map { slug in
                    .init(
                        template: "redirect",
                        context: Redirect(
                            url: site.permalink(material.slug)
                        ),
                        destination: site.destinationUrl
                            .appendingPathComponent(slug)
                            .appendingPathComponent(Files.index)
                    )
            }
        }
        .flatMap { $0 }
    }
}
