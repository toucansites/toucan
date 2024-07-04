//
//  File.swift
//
//
//  Created by Tibor Bodecs on 03/05/2024.
//

import Foundation
import Algorithms

/// Responsible to put together contextual objects.
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

    func permalink(
        _ value: String,
        _ baseUrl: String? = nil
    ) -> String {
        let baseUrl = baseUrl ?? contents.config.site.baseUrl
        let components = value.split(separator: "/").map(String.init)
        if components.isEmpty {
            return baseUrl
        }
        if components.last?.split(separator: ".").count ?? 0 > 1 {
            return baseUrl + components.joined(separator: "/")
        }
        return baseUrl + components.joined(separator: "/") + "/"
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

    func getOutputHTMLContext<T>(
        material: SourceMaterial,
        context: T,
        prev: String? = nil,
        next: String? = nil
    ) -> HTML<T> {
        let renderer = MarkdownToHTMLRenderer(
            delegate: HTMLRendererDelegate(
                config: contents.config,
                material: material
            )
        )
        
        // TODO: make this better
        let toc = renderer.toc(markdown: material.markdown)
        let tree = ToCTree.buildToCTree(from: toc)
        
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
                    imageUrl: material.imageUrl().map { permalink($0) },
                    noindex: contents.config.site.noindex || material.noindex,
                    canonical: material.canonical ?? permalink(material.slug),
                    hreflang: material.hreflang ?? 
                        contents.config.site.hreflang?.map {
                            .init(
                                lang: $0.lang,
                                url: permalink(material.slug, $0.url)
                            )
                        },
                    prev: prev,
                    next: next
                ),
                css: material.cssUrls(),
                js: material.jsUrls(),
                data: material.data,
                context: context,
                content: renderer.render(
                    markdown: material.markdown
                ),
                toc: tree
            ),
            userDefined: contents.config.userDefined
                .recursivelyMerged(with: material.userDefined),
            year: currentYear
        )
    }
    
    // MARK: - page contexts
    
//    func homePageContext() -> Context.Main.Home {
//        return .init(
//            featured: contents.blog.featuredPosts().map { $0.context(site: self) },
//            posts: contents.blog.latestPosts().map { $0.context(site: self) },
//            authors: contents.blog.authors.map { $0.context(site: self) },
//            tags: contents.blog.tags.map { $0.context(site: self) },
//            pages: []
//        )
//    }
    
}
