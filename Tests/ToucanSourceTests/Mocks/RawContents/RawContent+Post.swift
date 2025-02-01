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
                        path: "blog/posts/post-\(i)",
                        slug: "blog/posts/post-\(i)"
                    ),
                    frontMatter: [
                        "name": "Post #\(i)",
                        "publication": date,
                        "featured": (i % 2 == 0),
                        "authors": (0...(i / 3)).map { "author-\($0)" },
                        "tags": (0...(i / 3)).map { "tag-\($0)" },
                        //                        "authors": (1...10).shuffled().prefix(Int.random(in: 0...3)).map { "author-\($0)" },
                        //                        "tags": (1...10).shuffled().prefix(Int.random(in: 0...3)).map { "tag-\($0)" },
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
