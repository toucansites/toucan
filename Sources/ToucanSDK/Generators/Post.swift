import Foundation

struct Post {

    let meta: Meta
    let slug: String
    let date: Date
    let tags: [String]
    let html: String
    let postCoverImageHtml: String
    let config: Config
    let templatesUrl: URL
    let modificationDate: Date
    let userDefined: [String: String]

    func generate() throws -> String {

        let postTemplate = PostTemplate(
            templatesUrl: templatesUrl,
            context: .init(
                meta: meta,
                contents: html,
                postCoverImageHtml: postCoverImageHtml,
                date: config.formatter.string(from: date),
                tags: tags,
                userDefined: userDefined
            )
        )

        let indexTemplate = IndexTemplate(
            templatesUrl: templatesUrl,
            context: .init(
                meta: meta,
                contents: try postTemplate.render(),
                showMetaImage: !postCoverImageHtml.isEmpty
            )
        )
        return try indexTemplate.render()
    }

}
