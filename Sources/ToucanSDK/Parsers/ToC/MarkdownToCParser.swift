//
//  File.swift
//  toucan
//
//  Created by Viasz-Kádi Ferenc on 2024. 10. 14..
//

import Foundation
import Markdown

/// A parser that extracts table of contents elements from a Markdown document.
struct MarkdownToCParser: ToCElementParser {

    /// Parses a string containing Markdown content and returns an array of `TocElement` objects.
    ///
    /// - Parameter value: A string containing Markdown content.
    /// - Returns: An array of `TocElement` objects if headings are found, otherwise `nil`.
    func parse(from value: String) -> [TocElement]? {
        let document = Markdown.Document(parsing: value)
        var headingsVisitor = MarkupHeadingVisitor()
        return headingsVisitor.visitDocument(document)
    }
}

extension TocElement {

    /// Initializes a `TocElement` from a `Markdown.Heading`.
    ///
    /// - Parameter element: A `Markdown.Heading` from which to initialize the `TocElement`.
    init(_ element: Markdown.Heading) {
        level = element.level
        text = element.plainText
        fragment = text.lowercased().slugify()
    }
}
