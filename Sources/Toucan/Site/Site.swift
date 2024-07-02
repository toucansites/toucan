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
    
    // MARK: - page contexts
    
    

    
    
}
