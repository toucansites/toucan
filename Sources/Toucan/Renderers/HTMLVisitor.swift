//
//  File.swift
//
//
//  Created by Tibor Bodecs on 03/05/2024.
//

import Markdown

/// NOTE: https://www.markdownguide.org/basic-syntax/

extension Markup {

    var isInsideList: Bool {
        self is ListItemContainer || parent?.isInsideList == true
    }
}

enum TagType {
    case short
    case standard
}

struct Attribute {
    let key: String
    let value: String
}

enum Content {
    case value(String)
    case children(MarkupChildren)
}

struct HTMLVisitor: MarkupVisitor {

    typealias Result = String

    // MARK: - private functions

    private mutating func tag(
        name: String,
        type: TagType = .standard,
        attributes: [Attribute] = [],
        content: Content
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

    //    mutating func visit(_ markup: Markup) -> Result {
    //        fatalError()
    //    }

    mutating func visitBlockQuote(_ blockQuote: BlockQuote) -> Result {
        tag(name: "blockquote", content: .children(blockQuote.children))
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
                    content: .value(codeBlock.code)
                )
            )
        )
    }

    //    mutating func visitCustomBlock(_ customBlock: CustomBlock) -> Result {
    //        fatalError()
    //    }

    //    mutating func visitDocument(_ document: Document) -> Result {
    //        fatalError()
    //    }

    mutating func visitHeading(_ heading: Heading) -> Result {
        tag(
            name: "h\(heading.level)",
            content: .children(heading.children)
        )
    }

    mutating func visitThematicBreak(_ thematicBreak: ThematicBreak) -> Result {
        tag(name: "hr", type: .short, content: .value(""))
    }

    mutating func visitHTMLBlock(_ html: HTMLBlock) -> Result {
        html.rawHTML
    }

    mutating func visitListItem(_ listItem: ListItem) -> Result {
        tag(name: "li", content: .children(listItem.children))
    }

    mutating func visitOrderedList(_ orderedList: OrderedList) -> Result {
        tag(name: "ol", content: .children(orderedList.children))
    }

    mutating func visitUnorderedList(_ unorderedList: UnorderedList) -> Result {
        tag(name: "ul", content: .children(unorderedList.children))
    }

    mutating func visitParagraph(_ paragraph: Paragraph) -> Result {
        if paragraph.isInsideList {
            return paragraph.plainText
        }
        return tag(name: "p", content: .children(paragraph.children))
    }

    //    mutating func visitBlockDirective(_ blockDirective: BlockDirective) -> Result {
    //        fatalError()
    //    }

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
        return tag(
            name: "img",
            type: .short,
            attributes: [
                .init(key: "src", value: source),
                .init(key: "alt", value: image.plainText),
            ],
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
        tag(
            name: "a",
            attributes: [
                .init(
                    key: "href",
                    value: link.destination ?? "#"
                )
            ],
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
//
//        let bqModifier = Modifier(target: .blockquotes) { html, markdown in
//            if markdown.hasPrefix("> NOTE: ") {
//                return html.replacingOccurrences([
//                    "NOTE: ": "",
//                    "<p>": "<p class=\"note\">",
//                    "<blockquote>": "",
//                    "</blockquote>": "",
//                ])
//            }
//            if markdown.hasPrefix("> WARN: ") {
//                return html.replacingOccurrences([
//                    "WARN: ": "",
//                    "<p>": "<p class=\"warning\">",
//                    "<blockquote>": "",
//                    "</blockquote>": "",
//                ])
//            }
//            return html
//        }
//
//
//
//        let imageModifier = Modifier(target: .images) { html, markdown in
//            let input = String(markdown)
//            guard
//                let alt = input.slice(from: "![", to: "]"),
//                let file = input.slice(from: "](", to: ")"),
//                let name = file.split(separator: ".").first,
//                let ext = file.split(separator: ".").last,
//                assets.contains(file)
//            else {
//                print("[WARNING] Image link issues `\(input)` in `\(slug)`.")
//                return html
//            }
//
//            let darkFile = String(name) + "~dark." + String(ext)
//            let src = baseUrl + "images/assets/" + slug + "/images/" + file
//            let darkSrc =
//                baseUrl + "images/assets/" + slug + "/images/" + darkFile
//
//            var dark = ""
//            if assets.contains(darkFile) {
//                dark =
//                    #"<source srcset="\#(darkSrc)" media="(prefers-color-scheme: dark)">\#n\#t\#t"#
//            }
//            return #"""
//                </section><section class="wrapper">
//                <figure>
//                    <picture>
//                        \#(dark)<img class="post-image" src="\#(src)" alt="\#(alt)">
//                    </picture>
//                </figure>
//                </section><section class="content-wrapper">
//                """#
//        }
//