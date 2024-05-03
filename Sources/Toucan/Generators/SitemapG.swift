//import Foundation
//
//struct Sitemap {
//
//    let config: Config
//    let pages: [Page]
//    let posts: [Post]
//
//    func generate() throws -> String {
//        let sitemapTemplate = SitemapTemplate(
//            items: pages.map {
//                .init(permalink: $0.meta.permalink, date: $0.modificationDate)
//            }
//                + posts.map {
//                    .init(
//                        permalink: $0.meta.permalink,
//                        date: $0.modificationDate
//                    )
//                }
//        )
//        return try sitemapTemplate.render()
//    }
//
//}
