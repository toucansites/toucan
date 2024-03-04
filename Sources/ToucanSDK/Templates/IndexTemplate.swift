import Foundation

struct IndexTemplate {

    struct Context {
        let meta: Meta
        let contents: String
        let showMetaImage: Bool

        var templateVariables: [String: String] {
            meta.templateVariables + [
                "index-meta-image":
                    ((showMetaImage)
                    ? "<meta property=\"og:image\" content=\"{baseUrl}{image}\">"
                    : ""),
                "contents": contents,
            ]
        }
    }

    var file = "index.html"
    var templatesUrl: URL
    var context: Context

    init(
        templatesUrl: URL,
        context: Context
    ) {
        self.templatesUrl = templatesUrl
        self.context = context
    }

    func render() throws -> String {
        let templateUrl = templatesUrl.appendingPathComponent(file)
        let template = try String(contentsOf: templateUrl)
        return template.replacingTemplateVariables(context.templateVariables)
    }
}
