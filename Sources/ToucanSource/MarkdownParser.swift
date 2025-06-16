//
//  MarkdownParser.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 04. 17..
//

import Logging
import ToucanCore
import ToucanSerialization

/// A parser for Markdown content that extracts front matter metadata and body content.
///
/// Utilizes a configurable separator, a decoder conforming to `ToucanDecoder`, and a logger.
public struct MarkdownParser {
    // MARK: - Properties

    /// The string used to separate front matter from content in the markdown input.
    var separator: String
    /// A decoder used to parse front matter into a typed dictionary.
    var decoder: ToucanDecoder
    /// A logger used to emit parsing-related debug messages.
    var logger: Logger

    // MARK: - Lifecycle

    /// Creates a new `MarkdownParser` instance.
    ///
    /// - Parameters:
    ///   - separator: A string that separates front matter from content. Defaults to `"---"`.
    ///   - decoder: A decoder conforming to `ToucanDecoder` for parsing front matter.
    ///   - logger: A logger instance for emitting debug information. Defaults to a subsystem logger.
    public init(
        separator: String = "---",
        decoder: ToucanDecoder,
        logger: Logger = .subsystem("markdown-parser")
    ) {
        self.separator = separator
        self.decoder = decoder
        self.logger = logger
    }

    // MARK: - Functions

    /// Removes the front matter section from the given markdown string.
    ///
    /// - Parameter markdown: The markdown string containing optional front matter.
    /// - Returns: The markdown string without front matter.
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

    /// Parses the markdown string into front matter and body content.
    ///
    /// - Parameter markdown: A markdown string possibly containing front matter.
    /// - Returns: A `Markdown` instance containing parsed front matter and content.
    /// - Throws: An error if front matter decoding fails.
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

        // TODO: maybe check count
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
