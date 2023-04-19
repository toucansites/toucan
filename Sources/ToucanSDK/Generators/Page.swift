import Foundation

struct Page {

    let meta: Meta
    let slug: String
    let html: String
    let templatesUrl: URL
    let outputUrl: URL
    let modificationDate: Date

    func generate() throws {
        let pageTemplate = PageTemplate(
            templatesUrl: templatesUrl,
            context: .init(
                meta: meta,
                contents: html
            )
        )

        let indexTemplate = IndexTemplate(
            templatesUrl: templatesUrl,
            context: .init(
                meta: meta,
                contents: try pageTemplate.render()
            )
        )

        let htmlUrl =
            outputUrl
            .appendingPathComponent(slug)
            .appendingPathExtension("html")

        try indexTemplate.render().write(
            to: htmlUrl,
            atomically: true,
            encoding: .utf8
        )
    }
}
