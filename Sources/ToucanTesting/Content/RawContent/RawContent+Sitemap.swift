import Foundation
import ToucanModels

public extension RawContent.Mocks {

    static func sitemap() -> [RawContent] {
        [
            .init(
                origin: .init(
                    path: "sitemap.xml",
                    slug: "sitemap.xml"
                ),
                frontMatter: [
                    "type": "sitemap"
                ],
                markdown: """
                    """,
                lastModificationDate: Date().timeIntervalSince1970,
                assets: []
            )
        ]
    }
}
