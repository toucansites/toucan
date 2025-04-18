//
//  BlockDirectiveLoaderTestSuite.swift
//  Toucan
//
//  Created by Viasz-Kádi Ferenc on 2025. 02. 28..
//

import Foundation
import Testing
import ToucanContent
import ToucanModels
import ToucanTesting
import Logging
import FileManagerKitTesting
@testable import ToucanSource
@testable import ToucanSDK

@Suite
struct BlockDirectiveLoaderTestSuite {

    @Test
    func loadMarkdownBlockDirectives() throws {
        let logger = Logger(label: "BlockDirectiveLoaderTests")
        try FileManagerPlayground {
            Directory("themes") {
                Directory("default") {
                    Directory("blocks") {
                        File(
                            "highlighted-text.yml",
                            string: """
                                name: HighlightedText
                                tag: div
                                attributes:
                                  - name: class
                                    value: highlighted-text
                                """
                        )
                        File(
                            "button.yml",
                            string: """
                                name: Button
                                tag: a
                                parameters:
                                  - label: url
                                    default: ""
                                  - label: class
                                    default: "button"
                                  - label: target
                                    default: "_blank"
                                removesChildParagraph: true
                                attributes:
                                  - name: href
                                    value: "{{url}}"
                                  - name: target
                                    value: "{{target}}"
                                  - name: class
                                    value: "{{class}}"
                                """
                        )
                    }
                }
            }
        }
        .test {
            let url = $1.appending(path: "themes/default/blocks/")
            let overridesUrl = $1.appending(path: "themes/overrides/blocks/")

            let loader = BlockDirectiveLoader(
                url: url,
                overridesUrl: overridesUrl,
                locations: [
                    .init(path: "highlighted-text.yml", overridePath: nil),
                    .init(path: "button.yml", overridePath: nil),
                ],
                decoder: ToucanYAMLDecoder(),
                logger: logger
            )
            let result = try loader.load()

            #expect(
                result == [
                    .init(
                        name: "HighlightedText",
                        parameters: nil,
                        requiresParentDirective: nil,
                        removesChildParagraph: nil,
                        tag: "div",
                        attributes: [
                            MarkdownBlockDirective.Attribute(
                                name: "class",
                                value: "highlighted-text"
                            )
                        ],
                        output: nil
                    ),
                    .init(
                        name: "Button",
                        parameters: [
                            MarkdownBlockDirective.Parameter(
                                label: "url",
                                isRequired: nil,
                                defaultValue: ""
                            ),
                            MarkdownBlockDirective.Parameter(
                                label: "class",
                                isRequired: nil,
                                defaultValue: "button"
                            ),
                            MarkdownBlockDirective.Parameter(
                                label: "target",
                                isRequired: nil,
                                defaultValue: "_blank"
                            ),
                        ],
                        requiresParentDirective: nil,
                        removesChildParagraph: true,
                        tag: "a",
                        attributes: [
                            MarkdownBlockDirective.Attribute(
                                name: "href",
                                value: "{{url}}"
                            ),
                            MarkdownBlockDirective.Attribute(
                                name: "target",
                                value: "{{target}}"
                            ),
                            MarkdownBlockDirective.Attribute(
                                name: "class",
                                value: "{{class}}"
                            ),
                        ],
                        output: nil
                    ),
                ]
            )
        }
    }

    @Test
    func loadMarkdownBlockDirectivesOverride() throws {
        let logger = Logger(label: "BlockDirectiveLoaderTests")
        try FileManagerPlayground {
            Directory("themes") {
                Directory("default") {
                    Directory("blocks") {
                        File(
                            "highlighted-text.yml",
                            string: """
                                name: HighlightedText
                                tag: div
                                attributes:
                                  - name: class
                                    value: highlighted-text
                                """
                        )
                        File("button.yml", string: "")
                    }
                }
                Directory("overrides") {
                    Directory("blocks") {
                        File(
                            "button.yml",
                            string: """
                                name: Button
                                tag: a
                                parameters:
                                  - label: url
                                    default: ""
                                  - label: class
                                    default: "button"
                                  - label: target
                                    default: "_blank"
                                removesChildParagraph: true
                                attributes:
                                  - name: href
                                    value: "{{url}}"
                                  - name: target
                                    value: "{{target}}"
                                  - name: class
                                    value: "{{class}}"
                                """
                        )
                    }
                }
            }
        }
        .test {
            let url = $1.appending(path: "themes/default/blocks/")
            let overridesUrl = $1.appending(path: "themes/overrides/blocks/")

            let loader = BlockDirectiveLoader(
                url: url,
                overridesUrl: overridesUrl,
                locations: [
                    .init(path: "highlighted-text.yml", overridePath: nil),
                    .init(path: "button.yml", overridePath: "button.yml"),
                ],
                decoder: ToucanYAMLDecoder(),
                logger: logger
            )
            let result = try loader.load()

            #expect(
                result == [
                    .init(
                        name: "HighlightedText",
                        parameters: nil,
                        requiresParentDirective: nil,
                        removesChildParagraph: nil,
                        tag: "div",
                        attributes: [
                            MarkdownBlockDirective.Attribute(
                                name: "class",
                                value: "highlighted-text"
                            )
                        ],
                        output: nil
                    ),
                    .init(
                        name: "Button",
                        parameters: [
                            MarkdownBlockDirective.Parameter(
                                label: "url",
                                isRequired: nil,
                                defaultValue: ""
                            ),
                            MarkdownBlockDirective.Parameter(
                                label: "class",
                                isRequired: nil,
                                defaultValue: "button"
                            ),
                            MarkdownBlockDirective.Parameter(
                                label: "target",
                                isRequired: nil,
                                defaultValue: "_blank"
                            ),
                        ],
                        requiresParentDirective: nil,
                        removesChildParagraph: true,
                        tag: "a",
                        attributes: [
                            MarkdownBlockDirective.Attribute(
                                name: "href",
                                value: "{{url}}"
                            ),
                            MarkdownBlockDirective.Attribute(
                                name: "target",
                                value: "{{target}}"
                            ),
                            MarkdownBlockDirective.Attribute(
                                name: "class",
                                value: "{{class}}"
                            ),
                        ],
                        output: nil
                    ),
                ]
            )
        }
    }
}
