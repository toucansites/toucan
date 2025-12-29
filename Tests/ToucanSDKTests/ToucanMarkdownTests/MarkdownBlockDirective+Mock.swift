//
//  Block+Mock.swift
//  Toucan
//
//  Created by Binary Birds on 2025. 04. 17..

import Foundation
import ToucanSDK
import ToucanSource

public extension Block {
    enum Mocks {}
}

public extension Block.Mocks {
    static func highlightedTexts(
        max: Int = 10
    ) -> [Block] {
        (1...max)
            .map { i in
                .init(
                    name: "HighlightedText-\(i)",
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
