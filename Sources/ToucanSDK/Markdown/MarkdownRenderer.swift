//
//  File.swift
//
//
//  Created by Tibor Bodecs on 03/05/2024.
//

import Markdown

extension MarkdownRenderer.Delegate {

    func imageOverride(_ image: Image) -> String? {
        nil
    }

    func linkAttributes(_ link: String?) -> [String: String] {
        [:]
    }
}

/// A HTML renderer for Markdown documents.
public struct MarkdownRenderer {

    /// A delegate for the HTML renderer.
    public protocol Delegate {
        /// Override an image tag.
        func imageOverride(_ image: Image) -> String?
        /// Provide attributes for a link.
        func linkAttributes(_ link: String?) -> [String: String]
    }

    let delegate: Delegate?

    /// Public init.
    public init(
        delegate: Delegate? = nil
    ) {
        self.delegate = delegate
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
        var htmlVisitor = MarkupToHTMLVisitor(delegate: delegate)
        return htmlVisitor.visitDocument(document)
    }

    /// Render a Table of Contents
    public func renderToC(
        markdown: String
    ) -> [ToC] {
        let document = Document(
            parsing: markdown
        )
        var headingsVisitor = MarkupToHXVisitor()
        return Self.buildToC(headingsVisitor.visitDocument(document))
    }

    // MARK: - private

    static func buildToC(
        _ headings: [MarkupToHXVisitor.HX]
    ) -> [ToC] {
        var result: [ToC] = []
        var stack: [ToC] = []

        for heading in headings {
            let newNode = ToC(
                level: heading.level,
                text: heading.text,
                fragment: heading.fragment
            )

            // Find the correct parent for the current node
            while let last = stack.last, last.level >= heading.level {
                stack.removeLast()
            }

            if let parent = stack.last {
                // Append new node as a child of the last node in the stack
                var updatedParent = parent
                updatedParent.children.append(newNode)
                stack[stack.count - 1] = updatedParent
                if let index = result.firstIndex(where: {
                    $0.fragment == parent.fragment && $0.level == parent.level
                }) {
                    result[index] = updatedParent
                }
            }
            else {
                // Add the new node to the result if it has no parent
                result.append(newNode)
            }

            // Add the new node to the stack
            stack.append(newNode)
        }

        return result
    }
}
