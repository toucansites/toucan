import Foundation
import ToucanModels

public extension RawContent.Mocks {

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
                        path: "blog/posts/post-\(i)",
                        slug: "blog/posts/post-\(i)"
                    ),
                    frontMatter: [
                        "title": "Post #\(i)",
                        "publication": .init(date),
                        "featured": .init((i % 2 == 0)),
                        "authors": .init((0...(i / 3)).map { "author-\($0)" }),
                        "tags": .init((0...(i / 3)).map { "tag-\($0)" }),
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
