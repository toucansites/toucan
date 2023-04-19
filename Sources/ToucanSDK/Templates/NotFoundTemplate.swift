import Foundation

struct NotFoundTemplate {

    struct Context {
        let title: String
        let description: String
        let contents: String

        var templateVariables: [String: String] {
            [
                "404.title": title,
                "404.description": description,
                "contents": contents,
            ]
        }
    }

    var file = "404.html"
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
