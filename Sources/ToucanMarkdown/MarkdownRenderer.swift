//
//  File.swift
//  toucan
//
//  Created by Tibor Bodecs on 2025. 02. 19..
//

import Markdown
import Logging

struct MarkdownRenderer {

    public let customBlockDirectives: [CustomBlockDirective]
    public let logger: Logger

    public init(
        customBlockDirectives: [CustomBlockDirective] = [],
        logger: Logger = .init(label: "MarkdownRenderer")
    ) {
        self.customBlockDirectives = customBlockDirectives
        self.logger = logger
    }

    // MARK: - render api

    /// Render a Markdown string.
    public func renderHTML(
        markdown: String
    ) -> String {
        let document = Document(
            parsing: markdown,
            options: !customBlockDirectives.isEmpty
                ? [.parseBlockDirectives] : []
        )
        var htmlVisitor = HTMLVisitor(
            blockDirectives: customBlockDirectives,
            logger: logger
        )
        return htmlVisitor.visitDocument(document)
    }
}
