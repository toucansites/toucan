import Foundation

struct Home {

    let contentsDir: URL
    let config: Config
    let posts: [Post]
    let templatesDir: URL
    let outputDir: URL

    func generate() throws {
        let homeUrl = contentsDir.appendingPathComponent("home.md")
        let homeMeta = try MetadataParser().parse(at: homeUrl)

        let homePosts = posts.sorted { lhs, rhs in
            return lhs.date > rhs.date
        }
        .prefix(20)

        let homeContents = try homePosts.map { post in
            let homePostTemplate = HomePostTemplate(
                templatesDir: templatesDir,
                context: .init(
                    meta: post.meta,
                    date: config.formatter.string(from: post.date)
                )
            )
            return try homePostTemplate.render()
        }
        .joined(separator: "\n")

        let homeTemplate = HomeTemplate(
            templatesDir: templatesDir,
            context: .init(
                title: homeMeta["title"] ?? "",
                description: homeMeta["description"] ?? "",
                contents: homeContents
            )
        )

        let indexTemplate = IndexTemplate(
            templatesDir: templatesDir,
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
            outputDir
            .appendingPathComponent("index")
            .appendingPathExtension("html")

        try indexTemplate.render().write(
            to: indexOutputUrl,
            atomically: true,
            encoding: .utf8
        )
    }
}
