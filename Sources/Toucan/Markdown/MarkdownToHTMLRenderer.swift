//
//  File.swift
//
//
//  Created by Tibor Bodecs on 03/05/2024.
//

import Markdown

extension MarkdownToHTMLRenderer.Delegate {

    func imageOverride(_ image: Image) -> String? {
        nil
    }

    func linkAttributes(_ link: String?) -> [String: String] {
        [:]
    }
}

/// A HTML renderer for Markdown documents.
public struct MarkdownToHTMLRenderer {

    /// A delegate for the HTML renderer.
    public protocol Delegate {
        /// Override an image tag.
        func imageOverride(_ image: Image) -> String?
        /// Provide attributes for a link.
        func linkAttributes(_ link: String?) -> [String: String]
    }

    let delegate: Delegate?

    /// Public init.
    public init(delegate: Delegate? = nil) {
        self.delegate = delegate
    }

    /// Render a Markdown string.
    public func render(
        markdown: String
    ) -> String {
        let document = Document(
            parsing: markdown,
            options: .parseBlockDirectives
        )
        var htmlVisitor = MarkupToHTMLVisitor(delegate: delegate)

        return htmlVisitor.visitDocument(document)
    }
}
