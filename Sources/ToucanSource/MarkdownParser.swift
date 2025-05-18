//
//  MarkdownParser.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 04. 17..
//

import Logging
import ToucanSerialization

struct MarkdownParser {

    var separator: String = "---"
    var decoder: ToucanDecoder
    var logger: Logger

    private func dropFrontMatter(
        _ markdown: String
    ) -> String {
        if markdown.starts(with: separator) {
            return
                markdown
                .split(separator: separator)
                .dropFirst()
                .joined(separator: separator)
        }
        return markdown
    }

    func parse(
        _ markdown: String
    ) throws -> Markdown {
        guard markdown.starts(with: separator) else {
            return .init(
                frontMatter: [:],
                contents: markdown
            )
        }

        let parts = markdown.split(
            separator: separator,
            maxSplits: 1,
            omittingEmptySubsequences: true
        )

        // @TODO: maybe check count
        let rawFrontMatter = String(parts[0])
        let frontMatter = try decoder.decode(
            [String: AnyCodable].self,
            from: rawFrontMatter
        )
        return .init(
            frontMatter: frontMatter,
            contents: dropFrontMatter(markdown)
        )
    }
}
