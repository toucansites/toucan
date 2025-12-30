//
//  HTMLVisitor.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 02. 19..
//

import Logging
import Markdown
import ToucanCore
import ToucanSource
import Mustache

/// NOTE: https://www.markdownguide.org/basic-syntax/

private extension String {

    func escapeAngleBrackets() -> String {
        replacing(
            [
                #"<"#: #"&lt;"#,
                #">"#: #"&gt;"#,
                    // #"&"#: #"&amp;"#,
                    // #"'"#: #"&apos;"#,
                    // #"""#: #"&quot;"#,
            ]
        )
    }
}

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

struct HTMLVisitor: MarkupVisitor {
    typealias Result = String

    var customBlockDirectives: [Block]
    var paragraphStyles: [String: [String]]
    var codeBlockLanguagePrefix: String

    var logger: Logger

    var slug: String
    var assetsPath: String
    var baseURL: String

    var library: MustacheLibrary

    init(
        blockDirectives: [Block] = [],
        paragraphStyles: [String: [String]],
        codeBlockLanguagePrefix: String,
        slug: String,
        assetsPath: String,
        baseURL: String,
        logger: Logger = .subsystem("html-visitor")
    ) throws {
        self.customBlockDirectives = blockDirectives
        self.paragraphStyles = paragraphStyles
        self.codeBlockLanguagePrefix = codeBlockLanguagePrefix
        self.slug = slug
        self.assetsPath = assetsPath
        self.baseURL = baseURL
        self.logger = logger

        // convert template-based block directives to actual mustache templates
        let keyValuePairs: [(String, MustacheTemplate)] =
            try customBlockDirectives.compactMap { block in
                guard !block.view.isEmpty else {
                    return nil
                }
                return (
                    block.name.lowercased(),
                    try MustacheTemplate(string: block.view)
                )
            }

        let templatesById = Dictionary(keyValuePairs) { (first, _) in first }
        self.library = .init(templates: templatesById)
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
        html.rawHTML  //.escapeAngleBrackets()
    }

    mutating func visitInlineHTML(
        _ inlineHTML: InlineHTML
    ) -> Result {
        inlineHTML.rawHTML.escapeAngleBrackets()
    }

    // MARK: - simple HTML elements

    mutating func visitSoftBreak(
        _: SoftBreak
    ) -> Result {
        HTML(name: "br", type: .short).render()
    }

    mutating func visitLineBreak(
        _: LineBreak
    ) -> Result {
        HTML(name: "br", type: .short).render()
    }

    mutating func visitThematicBreak(
        _: ThematicBreak
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
        var attributes: [HTML.Attribute] = []
        if orderedList.startIndex > 1 {
            attributes.append(
                .init(
                    key: "start",
                    value: String(
                        orderedList.startIndex
                    )
                )
            )
        }
        return HTML(
            name: "ol",
            attributes: attributes,
            contents: visit(orderedList.children)
        )
        .render()
    }

    mutating func visitUnorderedList(
        _ unorderedList: UnorderedList
    ) -> Result {
        HTML(name: "ul", contents: visit(unorderedList.children)).render()
    }

    mutating func visitInlineCode(
        _ inlineCode: InlineCode
    ) -> Result {
        HTML(
            name: "code",
            contents: inlineCode.code.escapeAngleBrackets()
        )
        .render()
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
            .filter { $0.removeChildParagraph ?? false }
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

        var type: String?
        var dropCount = 0

        for i in blockQuote.children {
            if let p = i as? Paragraph {
                paragraphCount += 1
                let text = p.plainText.lowercased()

                typeLoop: for (typeValue, prefixes) in paragraphStyles {
                    for prefix in prefixes {
                        let fullPrefix = "\(prefix): ".lowercased()
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
                    value: "\(codeBlockLanguagePrefix)\(language.lowercased())"
                )
            )
        }
        let code = HTML(
            name: "code",
            attributes: attributes,
            contents: codeBlock.code
                .escapeAngleBrackets()
                .replacing(
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
                var hrefDestination = destination
                if destination.hasPrefix("/") {
                    hrefDestination =
                        "\(baseURL.ensureTrailingSlash())\(destination.dropFirst())"
                }
                attributes.append(
                    .init(
                        key: "href",
                        value: hrefDestination
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

    mutating func visitImage(_ image: Image) -> Result {
        guard let source = image.source, !source.isEmpty else {
            return ""
        }
        let imagePath = source.resolveAsset(
            baseURL: baseURL,
            assetsPath: assetsPath,
            slug: slug
        )
        var attributes: [HTML.Attribute] = [
            .init(key: "src", value: imagePath),
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

        let block = customBlockDirectives.first {
            $0.name.lowercased() == blockName.lowercased()
        }
        guard let block else {
            logger.warning(
                "Unrecognized block directive: `\(blockName)`",
                metadata: [
                    "name": .string(blockName)
                ]
            )
            return ""
        }

        guard parseErrors.isEmpty else {
            let errors =
                parseErrors.map { error -> String in
                    switch error {
                    case let .duplicateArgument(name, _, _):
                        return "Duplicate argument: `\(name)`."
                    case let .missingExpectedCharacter(char, _):
                        return "Misisng expected character: `\(char)`."
                    case let .unexpectedCharacter(char, _):
                        return "Unexpected character: `\(char)`."
                    }
                }
                .joined(separator: ", ")

            logger.warning(
                "\(errors)",
                metadata: [
                    "name": .string(blockName)
                ]
            )
            return ""
        }

        var parameters: [String: String] = [:]

        for (key, property) in block.properties.sorted(by: {
            $0.key < $1.key
        }) {
            // TODO: proper default value type handling
            if property.required {
                if let value = arguments.getFirstValueBy(key: key) {
                    if property.type == .asset {
                        let resolvedValue = value.resolveAsset(
                            baseURL: baseURL,
                            assetsPath: assetsPath,
                            slug: slug
                        )
                        parameters[key] = resolvedValue
                    }
                    else {
                        parameters[key] = value
                    }
                }
                else {
                    logger.warning(
                        "Parameter `\(key)` for `\(blockName)` is required.",
                        metadata: [
                            "name": .string(blockName)
                        ]
                    )
                }
            }
            else {
                let rawValue =
                    arguments.getFirstValueBy(
                        key: key
                    ) ?? property.defaultValue?.description  // TODO: fix this

                if property.type == .asset {
                    let resolvedValue = rawValue?
                        .resolveAsset(
                            baseURL: baseURL,
                            assetsPath: assetsPath,
                            slug: slug
                        )
                    parameters[key] = resolvedValue
                }
                else {
                    parameters[key] = rawValue

                }
            }
        }

        if let parent = block.requiredParentBlock, !parent.isEmpty {
            guard
                let p = blockDirective.parent as? BlockDirective,
                p.name.lowercased() == parent.lowercased()
            else {
                logger.warning(
                    "Block directive `\(block.name)` requires parent block `\(parent)`",
                    metadata: [
                        "name": .string(blockName)
                    ]
                )
                return ""
            }
        }

        var contents = ""
        for child in blockDirective.children {
            contents += visit(child)
        }

        parameters["contents"] = contents

        if block.resolveContentAsAssset ?? false {
            let resolvedValue = contents.resolveAsset(
                baseURL: baseURL,
                assetsPath: assetsPath,
                slug: slug
            )
            parameters["contents"] = resolvedValue
        }

        let result = library.render(parameters, withTemplate: blockName)
        return result ?? ""
    }

    // MARK: - TODO property type check + asset resolution

    //    func convert(
    //        property: Property,
    //        rawValue: AnyCodable?,
    //        forKey key: String,
    //        slug: String
    //    ) throws(ContentResolverError) -> AnyCodable? {
    //        let value = rawValue ?? property.defaultValue
    //
    //        switch property.type {
    //        case let .date(config):
    //            guard
    //                let rawDateValue = value?.value(as: String.self)
    //            else {
    //                throw .invalidProperty(
    //                    key,
    //                    value?.stringValue() ?? "nil",
    //                    slug
    //                )
    //            }
    //            guard
    //                let date = dateFormatter.date(
    //                    from: rawDateValue,
    //                    using: config
    //                )
    //            else {
    //                throw .invalidProperty(
    //                    key,
    //                    value?.stringValue() ?? "nil",
    //                    slug
    //                )
    //            }
    //            return .init(date.timeIntervalSince1970)
    //        default:
    //            return value
    //        }

    // asset resolution for properties...
    //        if let p = content.type.properties[k] {
    //            switch p.type {
    //            /// resolve assets

    //            /// format dates
    //            case .date:
    //                guard let rawValue = v.doubleValue() else {
    //                    continue
    //                }
    //                result[k] = .init(
    //                    dateFormatter.format(rawValue)
    //                )
    //            default:
    //                result[k] = .init(v.value)
    //            }
    //        }
    //        else {
    //            result[k] = .init(v.value)
    //        }
    //    }
}
