import Foundation

struct Home {

    let contentsUrl: URL
    let config: Config
    let posts: [Post]
    let templatesUrl: URL
    let outputUrl: URL

    func generate() throws {
        let homeUrl = contentsUrl.appendingPathComponent("home.md")
        let homeMeta = try MetadataParser().parse(at: homeUrl)

        let homePosts = posts.sorted { lhs, rhs in
            return lhs.date > rhs.date
        }
        .prefix(20)

        let homeContents = try homePosts.map { post in
            let homePostTemplate = HomePostTemplate(
                templatesUrl: templatesUrl,
                context: .init(
                    meta: post.meta,
                    date: config.formatter.string(from: post.date)
                )
            )
            return try homePostTemplate.render()
        }
        .joined(separator: "\n")

        let homeTemplate = HomeTemplate(
            templatesUrl: templatesUrl,
            context: .init(
                title: homeMeta["title"] ?? "",
                description: homeMeta["description"] ?? "",
                contents: homeContents
            )
        )

        let indexTemplate = IndexTemplate(
            templatesUrl: templatesUrl,
            context: .init(
                meta: .init(
                    site: config.title,
                    baseUrl: config.baseUrl,
                    slug: "",
                    title: homeMeta["title"] ?? "",
                    description: homeMeta["description"] ?? "",
                    image: homeMeta["image"] ?? ""
                ),
                contents: try homeTemplate.render()
            )
        )

        let indexOutputUrl =
            outputUrl
            .appendingPathComponent("index")
            .appendingPathExtension("html")

        try indexTemplate.render().write(
            to: indexOutputUrl,
            atomically: true,
            encoding: .utf8
        )
    }
}
