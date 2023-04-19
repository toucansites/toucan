import Foundation

struct RSS {

    let config: Config
    let posts: [Post]
    let outputDir: URL

    func generate() throws {
        let rssTemplate = RSSTemplate(
            items: posts.map {
                .init(
                    title: $0.meta.title,
                    description: $0.meta.description,
                    permalink: $0.meta.permalink,
                    date: $0.date
                )
            },
            config: config
        )

        let rssUrl =
            outputDir
            .appendingPathComponent("rss")
            .appendingPathExtension("xml")

        try rssTemplate.render().write(
            to: rssUrl,
            atomically: true,
            encoding: .utf8
        )
    }
}
