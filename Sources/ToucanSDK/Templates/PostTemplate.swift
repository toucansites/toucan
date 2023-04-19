import Foundation

struct PostTemplate {

    struct Context {
        let meta: Meta
        let contents: String
        let date: String
        let tags: [String]

        var templateVariables: [String: String] {
            meta.templateVariables + [
                "contents": contents,
                "date": date,
                "tags": tags.map { #"<span class="tag">\#($0)</span>"# }.joined(
                    separator: "\n"
                ),
            ]
        }
    }

    var file = "post.html"
    var templatesDir: URL
    var context: Context

    init(
        templatesDir: URL,
        context: Context
    ) {
        self.templatesDir = templatesDir
        self.context = context
    }

    func render() throws -> String {
        let templateUrl = templatesDir.appendingPathComponent(file)
        let template = try String(contentsOf: templateUrl)
        return template.replacingTemplateVariables(context.templateVariables)
    }
}
