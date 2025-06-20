//
//  Markdown.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 05. 18..
//

/// A representation of a Markdown document that includes front matter metadata and raw content.
///
/// This model is useful for parsing, transforming, and rendering Markdown files.
public struct Markdown: Equatable {

    /// A dictionary containing parsed front matter metadata.
    ///
    /// Typically includes key-value pairs defined at the top of the Markdown file (e.g., `title`, `author`, `date`).
    public var frontMatter: [String: AnyCodable]

    /// The body content of the Markdown file, excluding front matter.
    public var contents: String

    /// Initializes a new `Markdown` instance with front matter and Markdown content.
    ///
    /// - Parameters:
    ///   - frontMatter: A dictionary of metadata parsed from the front matter section.
    ///   - contents: The Markdown body as a string.
    public init(
        frontMatter: [String: AnyCodable] = [:],
        contents: String = ""
    ) {
        self.frontMatter = frontMatter
        self.contents = contents
    }
}
