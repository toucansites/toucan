//
//  File.swift
//  toucan
//
//  Created by Tibor Bodecs on 2025. 02. 19..
//

import Markdown
import Logging

/// NOTE: https://www.markdownguide.org/basic-syntax/

private extension Markup {

    var isInsideList: Bool {
        self is ListItemContainer || parent?.isInsideList == true
    }
}

private extension [DirectiveArgument] {

    func getFirstValueBy(key name: String) -> String? {
        first(where: { $0.name == name })?.value
    }
}

// MARK: - HTML visitor

struct HTMLVisitor: MarkupVisitor {

    typealias Result = String

    var customBlockDirectives: [MarkdownBlockDirective]
    var logger: Logger
    var baseUrl: String?

    init(
        blockDirectives: [MarkdownBlockDirective] = [],
        logger: Logger = .init(label: "HTMLVisitor"),
        baseUrl: String?
    ) {
        self.customBlockDirectives = blockDirectives
        self.logger = logger
        self.baseUrl = baseUrl
    }

    // MARK: - visitor functions

    private mutating func visit(
        _ children: MarkupChildren
    ) -> Result {
        var result = ""
        for child in children {
            result += visit(child)
        }
        return result
    }

    mutating func defaultVisit(
        _ markup: any Markup
    ) -> Result {
        visit(markup.children)
    }

    mutating func visitText(
        _ text: Text
    ) -> Result {
        text.plainText
    }

    mutating func visitHTMLBlock(
        _ html: HTMLBlock
    ) -> Result {
        html.rawHTML
    }

    mutating func visitInlineHTML(
        _ inlineHTML: InlineHTML
    ) -> Result {
        inlineHTML.rawHTML
    }

    // MARK: - simple HTML elements

    mutating func visitSoftBreak(
        _ softBreak: SoftBreak
    ) -> Result {
        HTML(name: "br", type: .short).render()
    }

    mutating func visitLineBreak(
        _ lineBreak: LineBreak
    ) -> Result {
        HTML(name: "br", type: .short).render()
    }

    mutating func visitThematicBreak(
        _ thematicBreak: ThematicBreak
    ) -> Result {
        HTML(name: "hr", type: .short).render()
    }

    mutating func visitListItem(
        _ listItem: ListItem
    ) -> Result {
        HTML(name: "li", contents: visit(listItem.children)).render()
    }

    mutating func visitOrderedList(
        _ orderedList: OrderedList
    ) -> Result {
        HTML(name: "ol", contents: visit(orderedList.children)).render()
    }

    mutating func visitUnorderedList(
        _ unorderedList: UnorderedList
    ) -> Result {
        HTML(name: "ul", contents: visit(unorderedList.children)).render()
    }

    mutating func visitInlineCode(
        _ inlineCode: InlineCode
    ) -> Result {
        HTML(name: "code", contents: inlineCode.code).render()
    }

    mutating func visitEmphasis(
        _ emphasis: Emphasis
    ) -> Result {
        HTML(name: "em", contents: visit(emphasis.children)).render()
    }

    mutating func visitStrong(
        _ strong: Strong
    ) -> Result {
        HTML(name: "strong", contents: visit(strong.children)).render()
    }

    mutating func visitStrikethrough(
        _ strikethrough: Strikethrough
    ) -> Result {
        HTML(name: "s", contents: visit(strikethrough.children)).render()
    }

    mutating func visitParagraph(
        _ paragraph: Paragraph
    ) -> Result {

        let filterBlocks =
            customBlockDirectives
            .filter { $0.removesChildParagraph ?? false }
            .map(\.name)

        if let block = paragraph.parent as? BlockDirective,
            filterBlocks.contains(block.name.lowercased())
        {
            return visit(paragraph.children)
        }
        /// if the parent is a list element, we don't need to render the p tag
        if paragraph.isInsideList {
            return visit(paragraph.children)
        }
        return HTML(name: "p", contents: visit(paragraph.children)).render()
    }

    mutating func visitBlockQuote(
        _ blockQuote: BlockQuote
    ) -> Result {
        var paragraphCount = 0
        var otherCount = 0

        // TODO: provide these from the outside
        let types: [String: [String]] = [
            "note": ["note"],
            "warning": ["warn", "warning"],
            "tip": ["tip"],
            "important": ["important"],
            "error": ["error", "caution"],
        ]

        var type: String?
        var dropCount = 0

        for i in blockQuote.children {
            if let p = i as? Paragraph {
                paragraphCount += 1
                let text = p.plainText.lowercased()

                typeLoop: for (typeValue, prefixes) in types {
                    for prefix in prefixes {
                        let fullPrefix = "\(prefix): "
                        if text.hasPrefix(fullPrefix) {
                            type = typeValue
                            dropCount = fullPrefix.count
                            break typeLoop
                        }
                    }
                }
            }
            else {
                otherCount += 1
            }
        }
        guard let type, otherCount == 0, paragraphCount == 1 else {
            return HTML(
                name: "blockquote",
                contents: visit(blockQuote.children)
            )
            .render()
        }
        let paragraph = visit(blockQuote.children)
        let pTagCount = 3
        let contents =
            paragraph.prefix(pTagCount)
            + paragraph.dropFirst(pTagCount).dropFirst(dropCount)
        return HTML(
            name: "blockquote",
            attributes: [
                .init(key: "class", value: type)
            ],
            contents: String(contents)
        )
        .render()
    }

    mutating func visitCodeBlock(
        _ codeBlock: CodeBlock
    ) -> Result {
        var attributes: [HTML.Attribute] = []
        if let language = codeBlock.language {
            attributes.append(
                .init(
                    key: "class",
                    value: "language-\(language.lowercased())"
                )
            )
        }
        let code = HTML(
            name: "code",
            attributes: attributes,
            contents: codeBlock.code
                .replacingOccurrences(
                    [
                        #"<"#: #"&lt;"#,
                        #">"#: #"&gt;"#,
                            //#"&"#: #"&amp;"#,
                            //#"'"#: #"&apos;"#,
                            //#"""#: #"&quot;"#,
                    ]
                )
                .replacingOccurrences(
                    [
                        #"/*!*/"#: #"<span class="highlight">"#,
                        #"/*.*/"#: "</span>",
                    ]
                )
        )
        .render()

        return HTML(name: "pre", contents: code).render()
    }

    mutating func visitHeading(
        _ heading: Heading
    ) -> Result {

        var attributes: [HTML.Attribute] = []
        if [2, 3].contains(heading.level) {
            let fragment = heading.plainText.lowercased().slugify()
            let id = HTML.Attribute(key: "id", value: "\(fragment)")
            attributes.append(id)

        }
        return HTML(
            name: "h\(heading.level)",
            attributes: attributes,
            contents: visit(heading.children)
        )
        .render()
    }

    mutating func visitLink(
        _ link: Link
    ) -> Result {
        var attributes: [HTML.Attribute] = []

        if let destination = link.destination {

            let anchorPrefix = "#[name]"
            if destination.hasPrefix(anchorPrefix) {
                attributes.append(
                    .init(
                        key: "name",
                        value: String(destination.dropFirst(anchorPrefix.count))
                    )
                )
            }
            else {
                attributes.append(
                    .init(
                        key: "href",
                        value: destination
                    )
                )
            }

            if !destination.hasPrefix("."),
                !destination.hasPrefix("/"),
                !destination.hasPrefix("#")
            {
                attributes.append(
                    .init(
                        key: "target",
                        value: "_blank"
                    )
                )
            }
        }

        return HTML(
            name: "a",
            attributes: attributes,
            contents: visit(link.children)
        )
        .render()
    }
    
    /*
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
    */

    mutating func visitImage(_ image: Image) -> Result {
        guard let source = image.source, !source.isEmpty else {
            return ""
        }
        
        //print("---------------")
        //print(image.source)

        // TODO: asset resolution?

        var attributes: [HTML.Attribute] = [
            .init(key: "src", value: source),
            .init(key: "alt", value: image.plainText),
        ]
        if let title = image.title {
            attributes.append(
                .init(key: "title", value: title)
            )
        }
        return HTML(
            name: "img",
            type: .short,
            attributes: attributes
        )
        .render()
    }

    // MARK: - table

    // TODO: alignment support
    mutating func visitTable(
        _ table: Table
    ) -> Result {
        HTML(name: "table", contents: visit(table.children)).render()
    }

    mutating func visitTableHead(
        _ tableHead: Table.Head
    ) -> Result {
        HTML(name: "thead", contents: visit(tableHead.children)).render()
    }

    mutating func visitTableBody(
        _ tableBody: Table.Body
    ) -> Result {
        HTML(name: "tbody", contents: visit(tableBody.children)).render()
    }

    mutating func visitTableRow(
        _ tableRow: Table.Row
    ) -> Result {
        HTML(name: "tr", contents: visit(tableRow.children)).render()
    }

    mutating func visitTableCell(
        _ tableCell: Table.Cell
    ) -> Result {
        HTML(name: "td", contents: visit(tableCell.children)).render()
    }

    // MARK: - custom block directives

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

        let block = customBlockDirectives.first {
            $0.name.lowercased() == blockName.lowercased()
        }
        guard let block else {
            logger.warning(
                "Unrecognized block directive: `\(blockName)`"
            )
            return ""
        }

        var parameters: [String: String] = [:]
        for p in block.parameters ?? [] {
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
            var contents = ""
            for child in blockDirective.children {
                contents += visit(child)
            }

            var params = templateParams
            params["{{contents}}"] = contents

            return output.replacingOccurrences(params)
        }

        if let name = block.tag {

            let attributes: [HTML.Attribute] =
                block.attributes?
                .map { a in
                    .init(
                        key: a.name,
                        value: a.value.replacingOccurrences(templateParams)
                    )
                } ?? []

            return HTML(
                name: name,
                attributes: attributes,
                contents: visit(blockDirective.children)
            )
            .render()
        }
        return ""
    }

}
