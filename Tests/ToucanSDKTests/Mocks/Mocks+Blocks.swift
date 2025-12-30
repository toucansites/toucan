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
            requiredParentBlock: nil,
            removeChildParagraph: true,
            properties: [
                "url": .init(
                    propertyType: .string,
                    isRequired: true,
                    defaultValue: ""
                ),
                "target": .init(
                    propertyType: .string,
                    isRequired: true,
                    defaultValue: "_blank"
                ),
                "class": .init(
                    propertyType: .string,
                    isRequired: true,
                    defaultValue: ""
                ),
            ],
            view: #"""
                <a href="{{url}}"{{#target}} target="{{.}}"{{/target}}{{#class}} class="{{.}}"{{/class}}>{{& contents}}</a>
                """#
        )
    }

    static func highlightedText(
        id: Int
    ) -> Block {
        .init(
            name: "HighlightedText-\(id)",
            requiredParentBlock: nil,
            removeChildParagraph: nil,
            properties: [:],
            view: #"""
                <div class="highlighted-text">{{& contents}}</div>
                """#
        )
    }

    static func faq() -> Block {
        .init(
            name: "FAQ",
            requiredParentBlock: nil,
            removeChildParagraph: nil,
            properties: [:],
            view: #"""
                <div class="faq">{{& contents}}</div>
                """#
        )
    }

    static func badDirective() -> Block {
        .init(
            name: "BAD",
            requiredParentBlock: "true",
            removeChildParagraph: nil,
            properties: [
                "label": .init(
                    propertyType: .string,
                    isRequired: true,
                    defaultValue: nil
                )
            ],
            view: #"""
                <div att="none">{{& contents}}</div>
                """#
        )
    }

    static func grid() -> Block {
        .init(
            name: "Grid",
            requiredParentBlock: nil,
            removeChildParagraph: true,
            properties: [
                "columns": .init(
                    propertyType: .int,
                    isRequired: true,
                    defaultValue: nil
                )

            ],
            view: #"""
                <div columns="grid-{{columns}}">{{& contents}}</div>
                """#
        )
    }
}
