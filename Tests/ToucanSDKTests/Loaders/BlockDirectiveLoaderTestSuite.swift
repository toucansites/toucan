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
import ToucanSerialization
@testable import ToucanSource
@testable import ToucanSDK

@Suite
struct BlockDirectiveLoaderTestSuite {

    @Test
    func loadMarkdownBlockDirectives() throws {
        let logger = Logger(label: "BlockDirectiveLoaderTests")
        try FileManagerPlayground {
            Directory("src") {
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
        .test {
            let url = $1.appending(path: "src/blocks/")

            let loader = BlockDirectiveLoader(
                url: url,
                locations: [
                    "highlighted-text.yml",
                    "button.yml",
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
