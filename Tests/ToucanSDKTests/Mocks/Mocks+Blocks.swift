//
//  Mocks+Blocks.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 05. 21..
//

import ToucanSource

extension Mocks.Blocks {

    static func link() -> Block {
        .init(
            name: "link",
            parameters: [
                .init(
                    label: "url",
                    isRequired: true,
                    defaultValue: ""
                ),
                .init(
                    label: "class",
                    isRequired: true,
                    defaultValue: ""
                ),
                .init(
                    label: "target",
                    isRequired: true,
                    defaultValue: "_blank"
                ),
            ],
            requiresParentDirective: nil,
            removesChildParagraph: true,
            tag: "a",
            attributes: [
                .init(name: "href", value: "{{url}}"),
                .init(name: "target", value: "{{target}}"),
                .init(name: "class", value: "{{class}}"),
            ],
            output: nil
        )
    }

    static func highlightedText(
        id: Int
    ) -> Block {
        .init(
            name: "HighlightedText-\(id)",
            parameters: nil,
            requiresParentDirective: nil,
            removesChildParagraph: nil,
            tag: "div",
            attributes: [
                .init(
                    name: "class",
                    value: "highlighted-text"
                )
            ],
            output: nil
        )
    }

    static func faq() -> Block {
        .init(
            name: "FAQ",
            parameters: nil,
            requiresParentDirective: nil,
            removesChildParagraph: nil,
            tag: "div",
            attributes: [
                .init(name: "class", value: "faq")
            ],
            output: nil
        )
    }

    static func badDirective() -> Block {
        .init(
            name: "BAD",
            parameters: [
                .init(
                    label: "label",
                    isRequired: true
                )
            ],
            requiresParentDirective: "true",
            removesChildParagraph: nil,
            tag: "div",
            attributes: [
                .init(name: "att", value: "none")
            ],
            output: nil
        )
    }

}
