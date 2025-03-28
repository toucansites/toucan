import Foundation
import ToucanModels

public extension RawContent.Mocks {

    static func rss() -> [RawContent] {
        [
            .init(
                origin: .init(
                    path: "rss.xml",
                    slug: "rss.xml"
                ),
                frontMatter: [
                    "type": "rss"
                ],
                markdown: """
                    """,
                lastModificationDate: Date().timeIntervalSince1970,
                assets: []
            )
        ]
    }
}
