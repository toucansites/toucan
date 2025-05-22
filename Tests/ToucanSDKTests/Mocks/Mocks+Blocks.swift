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
}
