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
        let slugs = pageBundles.map(\.context.slug)
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
        contentTypes.first { $0.id == pageBundle.type } ?? ContentType.default
    }

    func pageBundles(by contentType: String) -> [PageBundle] {
        pageBundles.filter { $0.type == contentType }
    }

    func rssPageBundles() -> [PageBundle] {
        contentTypes
            .filter { $0.id != ContentType.pagination.id }
            .filter { $0.rss == true }
            .flatMap {
                pageBundles(by: $0.id)
            }
            .sorted { $0.publication > $1.publication }
    }
    
    func sitemapPageBundles() -> [PageBundle] {
        pageBundles
            .filter { $0.type != ContentType.pagination.id }
            .sorted { $0.publication > $1.publication }
    }
}
