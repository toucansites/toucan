//
//  File.swift
//
//
//  Created by Tibor Bodecs on 13/06/2024.
//

import Foundation

struct Source {
    
    let url: URL
    let config: Config
    let contentTypes: [ContentType]
    let pageBundles: [PageBundle]


    func validateSlugs() throws {
        let slugs = pageBundles.map(\.slug)
        let uniqueSlugs = Set(slugs)
        guard slugs.count == uniqueSlugs.count else {
            var seenSlugs = Set<String>()
            var duplicateSlugs = Set<String>()

            for element in slugs {
                if seenSlugs.contains(element) {
                    duplicateSlugs.insert(element)
                }
                else {
                    seenSlugs.insert(element)
                }
            }

            for element in duplicateSlugs {
                fatalError("Duplicate slug: \(element)")
            }
            fatalError("Invalid slugs")
        }
    }

    func bundleContext() -> [String: [PageBundle]] {
        var result: [String: [PageBundle]] = [:]
        for contentType in contentTypes {
            for (key, _) in contentType.context?.site ?? [:] {
                // TODO: sort value order etc. + convert to ctx
                result[key] = pageBundlesBy(type: contentType.id)
            }
        }
        return result
    }
    
    func contentType(for pageBundle: PageBundle) -> ContentType {
        // TODO: proper fallback to page...?
        contentTypes.first { $0.id == pageBundle.type }!
    }

    func pageBundlesBy(type: String) -> [PageBundle] {
        pageBundles.filter { $0.type == type }
    }
    
    //    // MARK: - utilities
    //
//        func permalink(
//            _ value: String,
//            _ baseUrl: String? = nil
//        ) -> String {
//            let baseUrl = baseUrl ?? contents.config.site.baseUrl
//            let components = value.split(separator: "/").map(String.init)
//            if components.isEmpty {
//                return baseUrl
//            }
//            if components.last?.split(separator: ".").count ?? 0 > 1 {
//                return baseUrl + components.joined(separator: "/")
//            }
//            return baseUrl + components.joined(separator: "/") + "/"
//        }
    //
    //    func render(
    //        material: SourceMaterial
    //    ) -> String {
    //        let renderer = MarkdownToHTMLRenderer(
    //            delegate: HTMLRendererDelegate(
    //                config: contents.config,
    //                material: material
    //            )
    //        )
    //        return renderer.render(markdown: material.markdown)
    //    }
    //
    //    func readingTime(_ value: String) -> Int {
    //        value.split(separator: " ").count / 238
    //    }
    //
    //    // MARK: - context helpers
    //
    //    func getOutputHTMLContext<T>(
    //        material: SourceMaterial,
    //        context: T,
    //        prev: String? = nil,
    //        next: String? = nil
    //    ) -> HTML<T> {
    //        let renderer = MarkdownToHTMLRenderer(
    //            delegate: HTMLRendererDelegate(
    //                config: contents.config,
    //                material: material
    //            )
    //        )
    //
    //        // TODO: make this better
    //        let toc = renderer.toc(markdown: material.markdown)
    //        let tree = ToCTree.buildToCTree(from: toc)
    //
    //        return .init(
    //            site: .init(
    //                baseUrl: contents.config.site.baseUrl,
    //                title: contents.config.site.title,
    //                description: contents.config.site.description,
    //                language: contents.config.site.language
    //            ),
    //            page: .init(
    //                metadata: .init(
    //                    slug: material.slug,
    //                    permalink: permalink(material.slug),
    //                    title: material.title,
    //                    description: material.description,
    //                    imageUrl: material.imageUrl().map { permalink($0) },
    //                    noindex: contents.config.site.noindex || material.noindex,
    //                    canonical: material.canonical ?? permalink(material.slug),
    //                    hreflang: material.hreflang ??
    //                        contents.config.site.hreflang?.map {
    //                            .init(
    //                                lang: $0.lang,
    //                                url: permalink(material.slug, $0.url)
    //                            )
    //                        },
    //                    prev: prev,
    //                    next: next
    //                ),
    //                css: material.cssUrls(),
    //                js: material.jsUrls(),
    //                data: material.data,
    //                context: context,
    //                content: renderer.render(
    //                    markdown: material.markdown
    //                ),
    //                toc: tree
    //            ),
    //            userDefined: contents.config.userDefined
    //                .recursivelyMerged(with: material.userDefined),
    //            year: currentYear
    //        )
    //    }
    //
    
}

