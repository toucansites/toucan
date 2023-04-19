import Foundation

struct NotFound {

    let contentsDir: URL
    let config: Config
    let posts: [Post]
    let templatesDir: URL
    let outputDir: URL

    func generate() throws {
        let notFoundUrl = contentsDir.appendingPathComponent("404.md")
        let notFoundMeta = try MetadataParser().parse(at: notFoundUrl)
        let html = try ContentParser().parse(
            at: notFoundUrl,
            baseUrl: config.baseUrl,
            slug: "404",
            assets: []
        )

        let notFoundTemplate = NotFoundTemplate(
            templatesDir: templatesDir,
            context: .init(
                title: notFoundMeta["title"] ?? "",
                description: notFoundMeta["description"] ?? "",
                contents: html
            )
        )

        let indexTemplate = IndexTemplate(
            templatesDir: templatesDir,
            context: .init(
                meta: .init(
                    site: config.title,
                    baseUrl: config.baseUrl,
                    slug: "404",
                    title: notFoundMeta["title"] ?? "",
                    description: notFoundMeta["description"] ?? "",
                    image: notFoundMeta["image"] ?? ""
                ),
                contents: try notFoundTemplate.render()
            )
        )

        let indexOutputUrl =
            outputDir
            .appendingPathComponent("404")
            .appendingPathExtension("html")

        try indexTemplate.render().write(
            to: indexOutputUrl,
            atomically: true,
            encoding: .utf8
        )
    }
}
