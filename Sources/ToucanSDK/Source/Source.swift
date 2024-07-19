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
    
    func contentType(for pageBundle: PageBundle) -> ContentType {
        // TODO: proper fallback to page...?
        contentTypes.first { $0.id == pageBundle.type }!
    }

    func pageBundles(by contentType: String) -> [PageBundle] {
        pageBundles.filter { $0.type == contentType }
    }
    
    // MARK: - utilities

    func permalink(
        _ value: String,
        _ baseUrl: String? = nil
    ) -> String {
        let baseUrl = baseUrl ?? config.site.baseUrl
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
        pageBundle: PageBundle
    ) -> String {
        let renderer = MarkdownToHTMLRenderer(
            delegate: HTMLRendererDelegate(
                config: config,
                pageBundle: pageBundle
            )
        )
        return renderer.render(markdown: pageBundle.markdown)
    }
    
    func readingTime(_ value: String) -> Int {
        value.split(separator: " ").count / 238
    }    
}

