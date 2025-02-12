import Foundation
import ToucanModels

public extension RawContent.Mocks {

    static func tags(
        max: Int = 10
    ) -> [RawContent] {
        (1...max)
            .map { i in
                .init(
                    origin: .init(
                        path: "blog/tags/tag-\(i)",
                        slug: "blog/tags/tag-\(i)"
                    ),
                    frontMatter: [
                        "name": "Tag \(i)"
                    ],
                    markdown: """
                        # Tag #\(i)

                        Lorem ipsum dolor sit amet
                        """,
                    lastModificationDate: Date().timeIntervalSince1970,
                    assets: []
                )
            }
    }
}
