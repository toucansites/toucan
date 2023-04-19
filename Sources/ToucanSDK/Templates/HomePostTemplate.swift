import Foundation

struct HomePostTemplate {

    struct Context {
        let meta: Meta
        let date: String

        var templateVariables: [String: String] {
            meta.templateVariables + [
                "date": date
            ]
        }
    }

    var file = "home-post.html"
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
