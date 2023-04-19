import Foundation

struct Page {

    let meta: Meta
    let slug: String
    let html: String
    let templatesDir: URL
    let outputDir: URL
    let modificationDate: Date

    func generate() throws {
        let pageTemplate = PageTemplate(
            templatesDir: templatesDir,
            context: .init(
                meta: meta,
                contents: html
            )
        )

        let indexTemplate = IndexTemplate(
            templatesDir: templatesDir,
            context: .init(
                meta: meta,
                contents: try pageTemplate.render()
            )
        )

        let htmlUrl =
            outputDir
            .appendingPathComponent(slug)
            .appendingPathExtension("html")

        try indexTemplate.render().write(
            to: htmlUrl,
            atomically: true,
            encoding: .utf8
        )
    }
}
