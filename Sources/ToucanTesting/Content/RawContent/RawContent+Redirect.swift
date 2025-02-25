import Foundation
import ToucanModels

public extension RawContent.Mocks {

    static func redirectHomeOldAboutOld() -> [RawContent] {
        [
            .init(
                origin: .init(
                    path: "redirects/home-old",
                    slug: "home-2"
                ),
                frontMatter: [
                    "type": "redirect",
                    "to": "home",
                    "code": "301",
                ],
                markdown: """
                """,
                lastModificationDate: Date().timeIntervalSince1970,
                assets: []
            ),
            .init(
                origin: .init(
                    path: "redirects/about-old",
                    slug: "about-2"
                ),
                frontMatter: [
                    "type": "redirect",
                    "to": "about",
                    "code": "301",
                ],
                markdown: """
                """,
                lastModificationDate: Date().timeIntervalSince1970,
                assets: []
            )
        ]
    }
}
