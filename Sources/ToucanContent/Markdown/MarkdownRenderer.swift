//
//  File.swift
//  toucan
//
//  Created by Tibor Bodecs on 2025. 02. 19..
//

import Markdown
import ToucanModels
import Logging

public struct MarkdownToHTMLRenderer {

    public let customBlockDirectives: [MarkdownBlockDirective]
    public let paragraphStyles: ParagraphStyles
    public let logger: Logger

    public init(
        customBlockDirectives: [MarkdownBlockDirective] = [],
        paragraphStyles: ParagraphStyles,
        logger: Logger = .init(label: "MarkdownToHTMLRenderer")
    ) {
        self.customBlockDirectives = customBlockDirectives
        self.paragraphStyles = paragraphStyles
        self.logger = logger
    }

    // MARK: - render api

    /// Render a Markdown string.
    public func renderHTML(
        markdown: String,
        slug: String,
        assetsPath: String,
        baseUrl: String
    ) -> String {
        let document = Document(
            parsing: markdown,
            options: !customBlockDirectives.isEmpty
                ? [.parseBlockDirectives] : []
        )
        var htmlVisitor = HTMLVisitor(
            blockDirectives: customBlockDirectives,
            paragraphStyles: paragraphStyles,
            logger: logger,
            slug: slug,
            assetsPath: assetsPath,
            baseUrl: baseUrl
        )
        return htmlVisitor.visitDocument(document)
    }
}
