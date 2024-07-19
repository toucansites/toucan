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

    let source: Source

    let templatesUrl: URL
    let overridesUrl: URL
    let destinationUrl: URL

    let fileManager: FileManager = .default

    func render() throws {
        let renderer = try MustacheToHTMLRenderer(
            templatesUrl: templatesUrl,
            overridesUrl: overridesUrl
        )
        
        let context = source.bundleContext()
        
        for pageBundle in source.pageBundles {
            try render(
                renderer,
                .init(
                    template: pageBundle.template,
                    context: HTML(
                        site: .init(
                            baseUrl: "",
                            title: "",
                            description: "",
                            language: nil
                        ),
                        page: pageBundle,
                        context: context,
                        year: 2023
                    ),
                    destination: destinationUrl
                        .appendingPathComponent(pageBundle.slug)
                        .appendingPathComponent(Files.index)
                )
            )
        }

//        let home = home()
//        let notFound = notFound()
//        try render(renderer, home)
//        try render(renderer, notFound)
//        
//        // render rss & sitemap
//        let rss = rss()
//        let sitemap = sitemap()
//        
//        try render(renderer, rss)
//        try render(renderer, sitemap)
//        if let feed = feed() {
//            try render(renderer, feed)
//        }
//        
//        
//        
//        // MARK: - redirects
//
//        for renderable in redirects() {
//            try render(renderer, renderable)
//        }        
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
    
//    func blogPostListPaginated(
//    ) -> [Renderable<HTML<Context.Blog.Post.ListPage>>] {
//        guard let posts = site.source.materials.pages.blog.posts else {
//            return []
//        }
//
//        let pageLimit = Int(site.source.config.contents.pagination.limit)
//        let pages = site.contents.blog.posts.chunks(ofCount: pageLimit)
//
//        var result: [Renderable<HTML<Context.Blog.Post.ListPage>>] = []
//        for (index, postsChunk) in pages.enumerated() {
//            let pageNumber = index + 1
//            
//            
//            
//            let title = replacePaginationInfo(
//                current: pageNumber,
//                total: pages.count,
//                in: posts.title
//            )
//            let description = replacePaginationInfo(
//                current: pageNumber,
//                total: pages.count,
//                in: posts.description
//            )
//            let slug = replacePaginationInfo(
//                current: pageNumber,
//                total: pages.count,
//                in: posts.slug
//            )
//            
//            var prev: String? = nil
//            if index > 0 {
//                prev = replacePaginationInfo(
//                    current: pageNumber - 1,
//                    total: pages.count,
//                    in: posts.slug
//                )
//            }
//            
//            var next: String? = nil
//            if index < pages.count - 1 {
//                next = replacePaginationInfo(
//                    current: pageNumber - 1,
//                    total: pages.count,
//                    in: posts.slug
//                )
//            }
//
//            let material = posts.updated(
//                title: title,
//                description: description,
//                markdown: replacePaginationInfo(
//                    current: pageNumber,
//                    total: pages.count,
//                    in: posts.markdown
//                ),
//                slug: slug
//            )
//            let context = site.getOutputHTMLContext(
//                material: material,
//                context: Context.Blog.Post.ListPage(
//                    posts: postsChunk.map { $0.context(site: site) },
//                    pagination: (1...pages.count)
//                        .map {
//                            let slug = replacePaginationInfo(
//                                current: $0,
//                                total: pages.count,
//                                in: posts.slug
//                            )
//                            return .init(
//                                number: $0,
//                                total: pages.count,
//                                slug: slug,
//                                permalink: site.permalink(slug),
//                                isCurrent: pageNumber == $0
//                            )
//                        }
//                ),
//                prev: prev.map { site.permalink($0) },
//                next: next.map { site.permalink($0) }
//            )
//
//            let r = Renderable<HTML<Context.Blog.Post.ListPage>>(
//                template: material.template,
//                context: context,
//                destination: destinationUrl
//                    .appendingPathComponent(slug)
//                    .appendingPathComponent(Files.index)
//            )
//            
//            result.append(r)
//        }
//        return result
//    }
    
    
    func renderPageBundle(
        _ pageBundle: PageBundle
    ) throws {
        
        
    }
    
    // MARK: - rss
    
//    func rss() -> Renderable<RSS> {
//        let items: [RSS.Item] = site.contents.blog.posts.map { item in
//            let material = item.material
//            return .init(
//                permalink: site.permalink(material.slug),
//                title: material.title,
//                description: material.description,
//                publicationDate: site.rssDateFormatter.string(
//                    from: item.material.publication
//                )
//            )
//        }
//        
//        let publicationDate = items.first?.publicationDate ?? site.rssDateFormatter.string(from: .init())
//        
//        let context = RSS(
//            title: site.contents.config.site.title,
//            description: site.contents.config.site.description,
//            baseUrl: site.contents.config.site.baseUrl,
//            language: site.contents.config.site.language,
//            lastBuildDate: site.rssDateFormatter.string(from: .init()),
//            publicationDate: publicationDate,
//            items: items
//        )
//        
//        return .init(
//            template: "rss",
//            context: context,
//            destination: destinationUrl
//                .appendingPathComponent(Files.rss)
//        )
//    }
    
//    func feed() -> Renderable<Feed>? {
//        let userDefined = site.contents.config.userDefined
//        guard userDefined.value("podcast.feed", as: Bool.self) ?? false else {
//            return nil
//        }
//        let items: [Feed.Item] = site.contents.blog.posts.map { item in
//            let material = item.material
//            return .init(
//                permalink: site.permalink(material.slug),
//                title: material.title,
//                description: material.description,
//                publicationDate: site.rssDateFormatter.string(
//                    from: item.material.publication
//                )
//            )
//        }
//        
//        let publicationDate = items.first?.publicationDate ?? site.rssDateFormatter.string(from: .init())
//        
//        let context = Feed(
//            title: site.contents.config.site.title,
//            description: site.contents.config.site.description,
//            baseUrl: site.contents.config.site.baseUrl,
//            language: site.contents.config.site.language,
//            lastBuildDate: site.rssDateFormatter.string(from: .init()),
//            publicationDate: publicationDate,
//            items: items
//        )
//        
//        return .init(
//            template: "feed",
//            context: context,
//            destination: destinationUrl
//                .appendingPathComponent("podcast")
//                .appendingPathComponent(Files.feed)
//        )
//    }
    
    
    // MARK: - sitemap
    
//    func sitemap() -> Renderable<Sitemap> {
//        let context = Sitemap(
//            urls: site.source.materials.all()
//                .map { content in
//                        .init(
//                            location: site.permalink(content.slug),
//                            lastModification: site.sitemapDateFormatter.string(
//                                from: content.lastModification
//                            )
//                        )
//                }
//        )
//        return .init(
//            template: "sitemap",
//            context: context,
//            destination: destinationUrl
//                .appendingPathComponent(Files.sitemap)
//        )
//    }
//    
//    // MARK: - redirects
//    
//    func redirects() -> [Renderable<Redirect>] {
//        site.source.materials.all().map { material in
//            material.redirects.map { slug in
//                    .init(
//                        template: "redirect",
//                        context: Redirect(
//                            url: site.permalink(material.slug)
//                        ),
//                        destination: site.destinationUrl
//                            .appendingPathComponent(slug)
//                            .appendingPathComponent(Files.index)
//                    )
//            }
//        }
//        .flatMap { $0 }
//    }
}
