import Foundation

struct PageTemplate {

    struct Context {
        let meta: Meta
        let contents: String

        var templateVariables: [String: String] {
            meta.templateVariables + [
                "contents": contents
            ]
        }
    }

    var file = "page.html"
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
