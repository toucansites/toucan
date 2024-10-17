//
//  File.swift
//
//
//  Created by Tibor Bodecs on 03/05/2024.
//

import Markdown
import Logging

extension MarkdownRenderer.Delegate {

    func imageOverride(_ image: Image) -> String? {
        nil
    }

    func linkAttributes(_ link: String?) -> [String: String] {
        [:]
    }
}

/// A HTML renderer for Markdown documents.
struct MarkdownRenderer {

    /// A delegate for the HTML renderer.
    protocol Delegate {
        /// Override an image tag.
        func imageOverride(_ image: Image) -> String?
        /// Provide attributes for a link.
        func linkAttributes(_ link: String?) -> [String: String]
    }

    let blockDirectives: [Block]
    let delegate: Delegate?
    let logger: Logger

    /// Public init.
    init(
        blockDirectives: [Block],
        delegate: Delegate?,
        logger: Logger
    ) {
        self.blockDirectives = blockDirectives
        self.delegate = delegate
        self.logger = logger
    }

    // MARK: - render api

    /// Render a Markdown string.
    public func renderHTML(
        markdown: String
    ) -> String {
        let document = Document(
            parsing: markdown,
            options: .parseBlockDirectives
        )
        var htmlVisitor = MarkupToHTMLVisitor(
            blockDirectives: blockDirectives,
            delegate: delegate,
            logger: logger
        )
        return htmlVisitor.visitDocument(document)
    }
}
