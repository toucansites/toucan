import Foundation

struct Sitemap {

    let config: Config
    let pages: [Page]
    let posts: [Post]
    let outputDir: URL

    func generate() throws {
        let sitemapTemplate = SitemapTemplate(
            items: pages.map {
                .init(permalink: $0.meta.permalink, date: $0.modificationDate)
            }
                + posts.map {
                    .init(
                        permalink: $0.meta.permalink,
                        date: $0.modificationDate
                    )
                }
        )

        let sitemapUrl =
            outputDir
            .appendingPathComponent("sitemap")
            .appendingPathExtension("xml")

        try sitemapTemplate.render().write(
            to: sitemapUrl,
            atomically: true,
            encoding: .utf8
        )
    }
}
