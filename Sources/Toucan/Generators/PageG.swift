//import Foundation
//
//struct Page {
//
//    let meta: Meta
//    let slug: String
//    let html: String
//    let templatesUrl: URL
//    let modificationDate: Date
//
//    func generate() throws -> String {
//        let pageTemplate = PageTemplate(
//            templatesUrl: templatesUrl,
//            context: .init(
//                meta: meta,
//                contents: html
//            )
//        )
//
//        let indexTemplate = IndexTemplate(
//            templatesUrl: templatesUrl,
//            context: .init(
//                meta: meta,
//                contents: try pageTemplate.render(),
//                showMetaImage: true
//            )
//        )
//        return try indexTemplate.render()
//    }
//
//}
