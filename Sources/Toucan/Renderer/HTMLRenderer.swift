//
//  File.swift
//
//
//  Created by Tibor Bodecs on 03/05/2024.
//

import Markdown

/// A HTML renderer for Markdown documents.
public struct HTMLRenderer {

    /// Creates a new HTML renderer.
    public init() {

    }

    /// Render a Markdown string.
    public func render(
        markdown: String
    ) -> String {
        let document = Document(parsing: markdown)
        var htmlVisitor = HTMLVisitor()
        return htmlVisitor.visitDocument(document)
    }
}
