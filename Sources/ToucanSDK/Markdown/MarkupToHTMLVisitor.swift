//
//  File.swift
//
//
//  Created by Tibor Bodecs on 03/05/2024.
//

import Markdown
import Logging

/// NOTE: https://www.markdownguide.org/basic-syntax/

private extension Markup {

    var isInsideList: Bool {
        self is ListItemContainer || parent?.isInsideList == true
    }
}

private enum TagType {
    case short
    case standard
}

private struct Attribute {
    let key: String
    let value: String
}

private enum Contents {
    case value(String)
    case children(MarkupChildren)
}

private extension [DirectiveArgument] {

    func getFirstValueBy(key name: String) -> String? {
        first(where: { $0.name == name })?.value
    }
}

struct MarkupToHTMLVisitor: MarkupVisitor {

    typealias Result = String

    let blockDirectives: [Block]
    let delegate: MarkdownRenderer.Delegate?
    let logger: Logger

    init(
        blockDirectives: [Block],
        delegate: MarkdownRenderer.Delegate?,
        logger: Logger
    ) {
        self.blockDirectives = blockDirectives
        self.delegate = delegate
        self.logger = logger
    }

    // MARK: - private functions

    private mutating func tag(
        name: String,
        type: TagType = .standard,
        attributes: [Attribute] = [],
        content: Contents
    ) -> Result {
        let attributeString =
            attributes
            .map { #"\#($0.key)="\#($0.value)""# }
            .joined(separator: " ")

        let tag = [name, attributeString]
            .filter { !$0.isEmpty }
            .joined(separator: " ")

        var result = "<\(tag)>"

        switch content {
        case .value(let rawValue):
            result += rawValue
        case .children(let children):
            for child in children {
                result += visit(child)
            }
        }

        if type == .standard {
            result += "</\(name)>"
        }
        return result
    }

    // MARK: - visitor functions

    mutating func defaultVisit(_ markup: any Markup) -> Result {
        var result = ""
        for child in markup.children {
            result += visit(child)
        }
        return result
    }

    // MARK: - elements

    //        mutating func visit(_ markup: Markup) -> Result {
    //            fatalError()
    //        }

    mutating func visitBlockQuote(_ blockQuote: BlockQuote) -> Result {

        var paragraphCount = 0
        var otherCount = 0

        var type: String?
        for i in blockQuote.children {
            if let p = i as? Paragraph {
                paragraphCount += 1
                let text = p.plainText.lowercased()
                if text.hasPrefix("note:") {
                    type = "note"
                }
                if text.hasPrefix("warn:") || text.hasPrefix("warning:") {
                    type = "warning"
                }
                if text.hasPrefix("tip:") {
                    type = "tip"
                }
                if text.hasPrefix("important:") {
                    type = "important"
                }
                if text.hasPrefix("error:") || text.hasPrefix("caution:") {
                    type = "error"
                }
            }
            else {
                otherCount += 1
            }
        }
        guard let type, otherCount == 0, paragraphCount == 1 else {
            return tag(
                name: "blockquote",
                content: .children(blockQuote.children)
            )
        }
        return tag(
            name: "blockquote",
            attributes: [
                .init(key: "class", value: type)
            ],
            content: .children(blockQuote.children)
        )
    }

    mutating func visitCodeBlock(_ codeBlock: CodeBlock) -> Result {
        var attributes: [Attribute] = []
        if let language = codeBlock.language {
            attributes.append(
                .init(
                    key: "class",
                    value: "language-\(language.lowercased())"
                )
            )
        }
        return tag(
            name: "pre",
            content: .value(
                tag(
                    name: "code",
                    attributes: attributes,
                    content: .value(
                        codeBlock.code.replacingOccurrences(
                            [
                                "<": "&lt;",
                                ">": "&gt;",
                            ]
                        )
                    )
                )
            )
        )
    }

    //    mutating func visitCustomBlock(
    //        _ customBlock: CustomBlock
    //    ) -> Result {
    //        fatalError()
    //    }

    //    mutating func visitDocument(_ document: Document) -> Result {
    //        fatalError()
    //    }

    mutating func visitHeading(
        _ heading: Heading
    ) -> Result {

        var attributes: [Attribute] = []
        if [2, 3].contains(heading.level) {
            let fragment = heading.plainText.lowercased().slugify()
            let id = Attribute(key: "id", value: "\(fragment)")
            attributes.append(id)

        }
        return tag(
            name: "h\(heading.level)",
            attributes: attributes,
            content: .children(heading.children)
        )
    }

    mutating func visitThematicBreak(
        _ thematicBreak: ThematicBreak
    ) -> Result {
        tag(name: "hr", type: .short, content: .value(""))
    }

    mutating func visitHTMLBlock(
        _ html: HTMLBlock
    ) -> Result {
        html.rawHTML
    }

    mutating func visitListItem(
        _ listItem: ListItem
    ) -> Result {
        tag(name: "li", content: .children(listItem.children))
    }

    mutating func visitOrderedList(
        _ orderedList: OrderedList
    ) -> Result {
        tag(name: "ol", content: .children(orderedList.children))
    }

    mutating func visitUnorderedList(
        _ unorderedList: UnorderedList
    ) -> Result {
        tag(name: "ul", content: .children(unorderedList.children))
    }

    mutating func visitParagraph(
        _ paragraph: Paragraph
    ) -> Result {
        // NOTE: this is a bad workaround, but it works for now...
        /// if the parent is a link block directive
        if let block = paragraph.parent as? BlockDirective,
            ["link", "question"].contains(block.name.lowercased())
        {
            var result = ""
            for child in paragraph.children {
                result += visit(child)
            }
            return result
        }
        /// if the parent is a list element, we don't need to render the p tag
        if paragraph.isInsideList {
            var result = ""
            for child in paragraph.children {
                result += visit(child)
            }
            return result
        }

        return tag(name: "p", content: .children(paragraph.children))
    }

    mutating func visitBlockDirective(
        _ blockDirective: BlockDirective
    ) -> Result {
        var parseErrors = [DirectiveArgumentText.ParseError]()
        var arguments: [DirectiveArgument] = []
        let blockName = blockDirective.name.lowercased()
        if !blockDirective.argumentText.isEmpty {
            arguments = blockDirective.argumentText.parseNameValueArguments(
                parseErrors: &parseErrors
            )
        }
        guard parseErrors.isEmpty else {
            let errors =
                parseErrors
                .map { String(describing: $0) }
                .joined(separator: ", ")
            logger.warning("\(errors)")
            return ""
        }

        let block = blockDirectives.first {
            $0.name.lowercased() == blockName.lowercased()
        }
        guard let block else {
            logger.warning(
                "Unrecognized block directive: `\(blockName)`"
            )
            return ""
        }

        var parameters: [String: String] = [:]
        for p in block.params ?? [] {
            if p.required ?? false {
                if let v = arguments.getFirstValueBy(key: p.label) {
                    parameters[p.label] = v
                }
                else {
                    logger.warning(
                        "Parameter `\(p.label)` for `\(block.name)` is required."
                    )
                }
            }
            else {
                let v =
                    arguments.getFirstValueBy(key: p.label) ?? p.default ?? ""
                parameters[p.label] = v
            }
        }

        let templateParams = parameters.mapKeys { "{{\($0)}}" }

        if let parent = block.requiresParentDirective, !parent.isEmpty {

            guard
                let p = blockDirective.parent as? BlockDirective,
                p.name.lowercased() == parent.lowercased()
            else {
                logger.warning(
                    "Block directive `\(block.name)` requires parent block `\(parent)`."
                )
                return ""
            }
        }

        if let output = block.output {
            return output.replacingOccurrences(templateParams)
        }

        if let name = block.tag {

            let attributes: [Attribute] =
                block.attributes?
                .map { a in
                    .init(
                        key: a.name,
                        value: a.value.replacingOccurrences(templateParams)
                    )
                } ?? []

            return tag(
                name: name,
                attributes: attributes,
                content: .children(blockDirective.children)
            )
        }
        return ""
    }

    mutating func visitInlineCode(_ inlineCode: InlineCode) -> Result {
        tag(name: "code", content: .value(inlineCode.code))
    }

    //    mutating func visitCustomInline(_ customInline: CustomInline) -> Result {
    //        fatalError()
    //    }

    mutating func visitEmphasis(_ emphasis: Emphasis) -> Result {
        tag(name: "em", content: .children(emphasis.children))
    }

    mutating func visitImage(_ image: Image) -> Result {
        guard let source = image.source else {
            return ""
        }
        if let result = delegate?.imageOverride(image) {
            return result
        }
        var attributes: [Attribute] = [
            .init(key: "src", value: source),
            .init(key: "alt", value: image.plainText),
        ]
        if let title = image.title {
            attributes.append(
                .init(key: "title", value: title)
            )
        }
        return tag(
            name: "img",
            type: .short,
            attributes: attributes,
            content: .value("")
        )
    }

    mutating func visitInlineHTML(_ inlineHTML: InlineHTML) -> Result {
        inlineHTML.rawHTML
    }

    mutating func visitLineBreak(_ lineBreak: LineBreak) -> Result {
        tag(name: "br", type: .short, content: .value(""))
    }

    mutating func visitLink(_ link: Link) -> Result {
        var attributes: [Attribute] = []

        if let attr = delegate?.linkAttributes(link.destination) {
            for (key, value) in attr {
                attributes.append(.init(key: key, value: value))
            }
        }
        attributes.insert(
            .init(
                key: "href",
                value: link.destination ?? "#"
            ),
            at: 0
        )
        return tag(
            name: "a",
            attributes: attributes,
            content: .children(link.children)
        )
    }

    mutating func visitSoftBreak(_ softBreak: SoftBreak) -> Result {
        tag(name: "br", type: .short, content: .value(""))
    }

    mutating func visitStrong(_ strong: Strong) -> Result {
        tag(name: "strong", content: .children(strong.children))
    }

    mutating func visitText(_ text: Text) -> Result {
        text.plainText
    }

    mutating func visitStrikethrough(_ strikethrough: Strikethrough) -> Result {
        tag(name: "s", content: .children(strikethrough.children))
    }

    // NOTE: not supported yet...
    //    mutating func visitTable(_ table: Table) -> Result {
    //        fatalError()
    //    }
    //
    //    mutating func visitTableHead(_ tableHead: Table.Head) -> Result {
    //        fatalError()
    //    }
    //
    //    mutating func visitTableBody(_ tableBody: Table.Body) -> Result {
    //        fatalError()
    //    }
    //
    //    mutating func visitTableRow(_ tableRow: Table.Row) -> Result {
    //        fatalError()
    //    }
    //
    //    mutating func visitTableCell(_ tableCell: Table.Cell) -> Result {
    //        fatalError()
    //    }
    //
    //    mutating func visitSymbolLink(_ symbolLink: SymbolLink) -> Result {
    //        fatalError()
    //    }
    //
    //    mutating func visitInlineAttributes(_ attributes: InlineAttributes) -> Result {
    //        fatalError()
    //    }
    //
    //    mutating func visitDoxygenDiscussion(_ doxygenDiscussion: DoxygenDiscussion) -> Result {
    //        fatalError()
    //    }
    //
    //    mutating func visitDoxygenNote(_ doxygenNote: DoxygenNote) -> Result {
    //        fatalError()
    //    }
    //
    //    mutating func visitDoxygenParameter(_ doxygenParam: DoxygenParameter) -> Result {
    //        fatalError()
    //    }
    //
    //    mutating func visitDoxygenReturns(_ doxygenReturns: DoxygenReturns) -> Result {
    //        fatalError()
    //    }

}

//        let linkModifier = Modifier(target: .links) { html, markdown in
//            if !html.contains(baseUrl) {
//                return html.replacingOccurrences(
//                    of: "\">",
//                    with: "\" target=\"_blank\">"
//                )
//            }
//            return html
//        }
