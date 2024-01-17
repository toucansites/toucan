import Foundation

struct HomePostTemplate {

    struct Context {
        let meta: Meta
        let date: String
        let tags: [String]
        let userDefined: [String: String]

        var templateVariables: [String: String] {
            userDefined + meta.templateVariables + [
                "date": date,
                "tags": tags.map { #"<span class="tag">\#($0)</span>"# }
                    .joined(
                        separator: "\n"
                    ),
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
