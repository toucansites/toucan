//
//  MarkdownToHTMLRenderer.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 02. 19..
//

import Logging
import Markdown
import ToucanCore
import ToucanSource

/// A renderer that converts Markdown text to HTML, with support for custom block directives and paragraph styling.
public struct MarkdownToHTMLRenderer {

    /// Custom block directives to extend Markdown syntax.
    public let customBlockDirectives: [Block]

    /// A collection of paragraph styles.
    public let paragraphStyles: [String: [String]]

    /// Code block language prefix (e.g. `langauge-`, if needed for syntax highlighters), default: empty string.
    public let codeBlockLanguagePrefix: String

    /// Logger instance
    public let logger: Logger

    /// Initializes a `MarkdownToHTMLRenderer`.
    ///
    /// - Parameters:
    ///   - customBlockDirectives: A list of custom Markdown block directives to parse during rendering.
    ///   - paragraphStyles: The paragraph styles configuration for styling rendered HTML.
    ///   - codeBlockLanguagePrefix: Code block language prefix (e.g. `langauge-`, if needed for syntax highlighters), default: empty string.
    ///   - logger: A logger instance for logging. Defaults to a logger labeled "MarkdownToHTMLRenderer".
    public init(
        customBlockDirectives: [Block] = [],
        paragraphStyles: [String: [String]] = [:],
        codeBlockLanguagePrefix: String,
        logger: Logger = .subsystem("markdown-to-html-renderer")
    ) {
        self.customBlockDirectives = customBlockDirectives
        self.paragraphStyles = paragraphStyles
        self.codeBlockLanguagePrefix = codeBlockLanguagePrefix
        self.logger = logger
    }

    // MARK: - render api

    /// Renders the provided Markdown string to an HTML string.
    ///
    /// - Parameters:
    ///   - markdown: The input Markdown text to render.
    ///   - slug: A slug identifier used for generating.
    ///   - assetsPath: The path to the assets folder used for resource resolution.
    ///   - baseURL: The base URL used to resolve relative links within the Markdown.
    ///
    /// - Returns: A fully rendered HTML string.
    /// - Throws: An error if something went wrong with the HTML visitor setup.
    public func renderHTML(
        markdown: String,
        slug: String,
        assetsPath: String,
        baseURL: String
    ) throws -> String {
        // Create a Markdown document, enabling block directives if any are provided.
        let document = Document(
            parsing: markdown,
            options: !customBlockDirectives.isEmpty
                ? [.parseBlockDirectives] : []
        )

        // Initialize the HTML visitor with the current configuration.
        var htmlVisitor = try HTMLVisitor(
            blockDirectives: customBlockDirectives,
            paragraphStyles: paragraphStyles,
            codeBlockLanguagePrefix: codeBlockLanguagePrefix,
            slug: slug,
            assetsPath: assetsPath,
            baseURL: baseURL
        )

        // Generate HTML by visiting the document tree.
        return htmlVisitor.visitDocument(document)
    }
}
