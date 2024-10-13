//
//  File.swift
//  toucan
//
//  Created by Tibor Bodecs on 2024. 10. 13..
//

import Foundation

struct SitemapRenderer {
    
    public enum Files {
        static let sitemap = "sitemap.xml"
    }

    let destinationUrl: URL
    let fileManager: FileManager
    let templateRenderer: MustacheToHTMLRenderer
    let pageBundles: [PageBundle]

    func renderSitemap() throws {
        let sitemapDateFormatter = DateFormatters.sitemap
        let context = SitemapContext(
            urls: pageBundles
                .map {
                    .init(
                        location: $0.permalink,
                        lastModification: sitemapDateFormatter.string(
                            from: $0.lastModification
                        )
                    )
                }
        )
        try templateRenderer.render(
            template: "sitemap",
            with: context,
            to: destinationUrl.appendingPathComponent(Files.sitemap)
        )
    }
    
}
