import Foundation

struct RSSTemplate {

    struct Item {
        let title: String
        let description: String
        let permalink: String
        let date: Date
    }

    let formatter: DateFormatter = {
        let formatter = DateFormatter()
//        formatter.locale = .init(identifier: "en_US_POSIX")
        formatter.setLocalizedDateFormatFromTemplate(
            "EEE, dd MMM yyyy HH:mm:ss Z"
        )
        return formatter
    }()

    let items: [Item]
    let config: Config

    init(items: [Item], config: Config) {
        self.items = items
        self.config = config
    }

    func render() throws -> String {
        let date = Date()
        let now = formatter.string(from: date)

        let sorteditems = items.sorted { $0.date > $1.date }

        let contents = sorteditems.map { item in
            """
                <item>
                   <guid isPermaLink="true">\(item.permalink)</guid>
                   <title><![CDATA[ \(item.title) ]]></title>
                   <description><![CDATA[ \(item.description) ]]></description>
                   <link>\(item.permalink)</link>
                   <pubDate>\(formatter.string(from: item.date))</pubDate>
                </item>
            """
        }
        .joined(separator: "\n")

        let pubDate = sorteditems.first?.date ?? .init()

        return """
            <rss xmlns:atom="http://www.w3.org/2005/Atom" version="2.0">
            <channel>
                <title>\(config.title)</title>
                <description>\(config.description)</description>
                <link>\(config.baseUrl)</link>
                <language>\(config.language)</language>
                <lastBuildDate>\(now)</lastBuildDate>
                <pubDate>\(formatter.string(from: pubDate))</pubDate>
                <ttl>250</ttl>
                <atom:link href="\(config.baseUrl)rss.xml" rel="self" type="application/rss+xml"/>\n
            \(contents)
            </channel>
            </rss>
            """
    }
}
