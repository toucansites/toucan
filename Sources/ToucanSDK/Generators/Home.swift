import Foundation

struct Home {

    let contentsUrl: URL
    let config: Config
    let posts: [Post]
    let templatesUrl: URL

    func generate() throws -> String {
        let homeUrl = contentsUrl.appendingPathComponent("home.md")
        let homeMeta = try MetadataParser().parse(at: homeUrl)

        let homePosts =
            posts.sorted { lhs, rhs in
                return lhs.date > rhs.date
            }
            .prefix(20)

        let homeContents =
            try homePosts.map { post in
                var hidden = "hidden"
                if post.hasPostCoverImage {
                    hidden = ""
                }
                let homePostTemplate = HomePostTemplate(
                    templatesUrl: templatesUrl,
                    context: .init(
                        meta: post.meta,
                        date: config.formatter.string(from: post.date),
                        hidden: hidden,
                        tags: post.tags,
                        userDefined: post.userDefined
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
                    image: homeMeta["image"] ?? "",
                    language: config.language
                ),
                contents: try homeTemplate.render(),
                showMetaImage: true
            )
        )
        return try indexTemplate.render()
    }

}
