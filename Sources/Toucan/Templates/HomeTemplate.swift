//import Foundation
//
//struct HomeTemplate {
//
//    struct Context {
//        let title: String
//        let description: String
//        let contents: String
//
//        var templateVariables: [String: String] {
//            [
//                "home.title": title,
//                "home.description": description,
//                "contents": contents,
//            ]
//        }
//    }
//
//    var file = "home.html"
//    var templatesUrl: URL
//    var context: Context
//
//    init(
//        templatesUrl: URL,
//        context: Context
//    ) {
//        self.templatesUrl = templatesUrl
//        self.context = context
//    }
//
//    func render() throws -> String {
//        let templateUrl = templatesUrl.appendingPathComponent(file)
//        let template = try String(contentsOf: templateUrl)
//        return template.replacingTemplateVariables(context.templateVariables)
//    }
//}
