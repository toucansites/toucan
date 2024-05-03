//import Foundation
//
//struct NotFound {
//
//    let contentsUrl: URL
//    let config: Config
//    let posts: [Post]
//    let templatesUrl: URL
//
//    func generate() throws -> String {
//        let notFoundUrl = contentsUrl.appendingPathComponent("404.md")
//        //        let notFoundMeta = try MetadataParser().parse(at: notFoundUrl)
//        //        let html = try ContentParser()
//        //            .parse(
//        //                at: notFoundUrl,
//        //                baseUrl: config.baseUrl,
//        //                slug: "404",
//        //                assets: []
//        //            )
//        //
//        //        let notFoundTemplate = NotFoundTemplate(
//        //            templatesUrl: templatesUrl,
//        //            context: .init(
//        //                title: notFoundMeta["title"] ?? "",
//        //                description: notFoundMeta["description"] ?? "",
//        //                contents: html
//        //            )
//        //        )
//        //
//        //        let indexTemplate = IndexTemplate(
//        //            templatesUrl: templatesUrl,
//        //            context: .init(
//        //                meta: .init(
//        //                    site: config.title,
//        //                    baseUrl: config.baseUrl,
//        //                    slug: "404",
//        //                    title: notFoundMeta["title"] ?? "",
//        //                    description: notFoundMeta["description"] ?? "",
//        //                    image: notFoundMeta["image"] ?? "",
//        //                    language: config.language
//        //                ),
//        //                contents: try notFoundTemplate.render(),
//        //                showMetaImage: true
//        //            )
//        //        )
//        //        return try indexTemplate.render()
//        fatalError()
//    }
//
//}
