import Foundation

struct RSS {

    let config: Config
    let posts: [Post]

    func generate() throws -> String {
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

        return try rssTemplate.render()
    }

}
