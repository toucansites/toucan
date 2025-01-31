import Foundation
import ToucanModels

extension RawContent.Mocks {

    static func posts(
        max: Int = 10
    ) -> [RawContent] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        let now = Date()

        return (1...max)
            .map { i in
                let diff = Double(max - i) * -86_400
                let pastDate = now.addingTimeInterval(diff)
                let date = formatter.string(from: pastDate)
                return .init(
                    origin: .init(
                        path: "docs/categories/category-\(i)",
                        slug: "docs/categories/category-\(i)"
                    ),
                    frontMatter: [
                        "name": "Post #\(i)",
                        "date": date,
                        "featured": (i % 2 == 0),
                        "authors": [i].map { "author-\($0)" },
                        "tags": [i].map { "tag-\($0)" },
                    ],
                    markdown: """
                        # Post #\(i)

                        Lorem ipsum dolor sit amet
                        """,
                    lastModificationDate: Date().timeIntervalSince1970,
                    assets: []
                )
            }
    }
}
