//
//  MarkdownToHTMLRenderer.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 02. 19..
//

import Logging
import Markdown
import ToucanCore

/// A renderer that converts Markdown text to HTML, with support for custom block directives and paragraph styling.
public struct MarkdownToHTMLRenderer {
    /// Custom block directives to extend Markdown syntax.
    public let customBlockDirectives: [MarkdownBlockDirective]

    /// A collection of paragraph styles.
    public let paragraphStyles: [String: [String]]

    /// Logger instance
    public let logger: Logger

    /// Initializes a `MarkdownToHTMLRenderer`.
    ///
    /// - Parameters:
    ///   - customBlockDirectives: A list of custom Markdown block directives to parse during rendering.
    ///   - paragraphStyles: The paragraph styles configuration for styling rendered HTML.
    ///   - logger: A logger instance for logging. Defaults to a logger labeled "MarkdownToHTMLRenderer".
    public init(
        customBlockDirectives: [MarkdownBlockDirective] = [],
        paragraphStyles: [String: [String]] = [:],
        logger: Logger = .subsystem("markdown-to-html-renderer")
    ) {
        self.customBlockDirectives = customBlockDirectives
        self.paragraphStyles = paragraphStyles
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
    public func renderHTML(
        markdown: String,
        slug: String,
        assetsPath: String,
        baseURL: String
    ) -> String {
        // Create a Markdown document, enabling block directives if any are provided.
        let document = Document(
            parsing: markdown,
            options: !customBlockDirectives.isEmpty
                ? [.parseBlockDirectives] : []
        )

        // Initialize the HTML visitor with the current configuration.
        var htmlVisitor = HTMLVisitor(
            blockDirectives: customBlockDirectives,
            paragraphStyles: paragraphStyles,
            slug: slug,
            assetsPath: assetsPath,
            baseURL: baseURL
        )

        // Generate HTML by visiting the document tree.
        return htmlVisitor.visitDocument(document)
    }
}
