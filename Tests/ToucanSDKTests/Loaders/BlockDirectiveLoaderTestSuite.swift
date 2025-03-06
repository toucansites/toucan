//
//  File.swift
//  toucan
//
//  Created by Viasz-Kádi Ferenc on 2025. 02. 28..
//

import Foundation
import Testing
import ToucanContent
import ToucanModels
import ToucanTesting
import FileManagerKitTesting
@testable import ToucanSource
@testable import ToucanSDK

@Suite
struct BlockDirectiveLoaderTestSuite {

    @Test
    func loadMarkdownBlockDirectives() throws {

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
                yamlParser: YamlParser(),
                logger: .init(label: "BlockDirectiveLoaderTests")
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
                                required: nil,
                                default: ""
                            ),
                            MarkdownBlockDirective.Parameter(
                                label: "class",
                                required: nil,
                                default: "button"
                            ),
                            MarkdownBlockDirective.Parameter(
                                label: "target",
                                required: nil,
                                default: "_blank"
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
                yamlParser: YamlParser(),
                logger: .init(label: "BlockDirectiveLoaderTests")
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
                                required: nil,
                                default: ""
                            ),
                            MarkdownBlockDirective.Parameter(
                                label: "class",
                                required: nil,
                                default: "button"
                            ),
                            MarkdownBlockDirective.Parameter(
                                label: "target",
                                required: nil,
                                default: "_blank"
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
