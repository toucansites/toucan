//import Foundation
//
//struct SitemapTemplate {
//
//    struct Item {
//        let permalink: String
//        let date: Date
//    }
//
//    var items: [Item]
//
//    let formatter: DateFormatter = {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy-MM-dd"
//        return formatter
//    }()
//
//    init(items: [Item]) {
//        self.items = items
//    }
//
//    func render() throws -> String {
//        let contents = items.sorted { $0.date > $1.date }
//            .map { item in
//                """
//                    <url>
//                        <loc>\(item.permalink)</loc>
//                        <lastmod>\(formatter.string(from: item.date))</lastmod>
//                    </url>
//                """
//            }
//            .joined(separator: "\n")
//
//        return """
//            <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
//            \(contents)
//            </urlset>
//            """
//    }
//}
