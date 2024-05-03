//import Foundation
//
//struct Post {
//
//    let meta: Meta
//    let slug: String
//    let date: Date
//    let tags: [String]
//    let html: String
//    let hasPostCoverImage: Bool
//    let config: Config
//    let templatesUrl: URL
//    let modificationDate: Date
//    let userDefined: [String: String]
//
//    func generate() throws -> String {
//
//        let postTemplate = PostTemplate(
//            templatesUrl: templatesUrl,
//            context: .init(
//                meta: meta,
//                contents: html,
//                hasPostCoverImage: hasPostCoverImage,
//                date: config.formatter.string(from: date),
//                tags: tags,
//                userDefined: userDefined
//            )
//        )
//        let indexTemplate = IndexTemplate(
//            templatesUrl: templatesUrl,
//            context: .init(
//                meta: meta,
//                contents: try postTemplate.render(),
//                showMetaImage: hasPostCoverImage
//            )
//        )
//        return try indexTemplate.render()
//    }
//
//}
