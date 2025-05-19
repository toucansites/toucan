//
//  MarkdownParser.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 04. 17..
//

import Logging
import ToucanCore
import ToucanSerialization

public struct MarkdownParser {

    var separator: String
    var decoder: ToucanDecoder
    var logger: Logger

    public init(
        separator: String = "---",
        decoder: ToucanDecoder,
        logger: Logger = .subsystem("markdown-parser")
    ) {
        self.separator = separator
        self.decoder = decoder
        self.logger = logger
    }

    func dropFrontMatter(
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

    public func parse(
        _ markdown: String
    ) throws -> Markdown {
        guard markdown.starts(with: separator) else {
            logger.debug("The markdown string has no front matter.")
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
                .trimmingCharacters(
                    in: .whitespacesAndNewlines
                )
        )
    }
}
