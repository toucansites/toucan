//
//  MarkdownBlockDirectiveTestSuite.swift
//  Toucan
//
//  Created by Binary Birds on 2025. 04. 17..

import Logging
import Testing

@testable import ToucanMarkdown

@Suite
struct MarkdownBlockDirectiveTestSuite {
    @Test
    func simpleCustomBlockDirective() throws {
        let renderer = MarkdownToHTMLRenderer(
            customBlockDirectives: [
                MarkdownBlockDirective.Mocks.faq()
            ],
            paragraphStyles: [:]
        )

        let input = #"""
            @FAQ {
                Lorem ipsum
            }
            """#

        let output = renderer.renderHTML(
            markdown: input,
            slug: "",
            assetsPath: "",
            baseURL: ""
        )

        let expectation = #"""
            <div class="faq"><p>Lorem ipsum</p></div>
            """#

        #expect(output == expectation)
    }

    @Test
    func simpleCustomBlockDirectiveUsingOutput() throws {
        let renderer = MarkdownToHTMLRenderer(
            customBlockDirectives: [
                .init(
                    name: "FAQ",
                    parameters: nil,
                    requiresParentDirective: nil,
                    removesChildParagraph: nil,
                    tag: nil,
                    attributes: nil,
                    output: #"<div class="faq">{{contents}}</div>"#
                )
            ],
            paragraphStyles: [:]
        )

        let input = #"""
            @FAQ {
                Lorem ipsum
            }
            """#

        let output = renderer.renderHTML(
            markdown: input,
            slug: "",
            assetsPath: "",
            baseURL: ""
        )

        let expectation = #"""
            <div class="faq"><p>Lorem ipsum</p></div>
            """#

        #expect(output == expectation)
    }

    @Test
    func customBlockDirectiveParameters() throws {
        let renderer = MarkdownToHTMLRenderer(
            customBlockDirectives: [
                .init(
                    name: "Grid",
                    parameters: [
                        .init(
                            label: "columns",
                            isRequired: true,
                            defaultValue: nil
                        )
                    ],
                    requiresParentDirective: nil,
                    removesChildParagraph: nil,
                    tag: "div",
                    attributes: [
                        .init(name: "columns", value: "grid-{{columns}}")
                    ],
                    output: nil
                )
            ],
            paragraphStyles: [:]
        )

        let input = #"""
            @Grid(columns: 3) {
                Lorem ipsum
            }
            """#

        let output = renderer.renderHTML(
            markdown: input,
            slug: "",
            assetsPath: "",
            baseURL: ""
        )

        let expectation = #"""
            <div columns="grid-3"><p>Lorem ipsum</p></div>
            """#

        #expect(output == expectation)
    }

    @Test
    func customBlockDirectiveParametersUsingOutput() throws {
        let renderer = MarkdownToHTMLRenderer(
            customBlockDirectives: [
                .init(
                    name: "Grid",
                    parameters: [
                        .init(
                            label: "columns",
                            isRequired: true,
                            defaultValue: nil
                        )
                    ],
                    requiresParentDirective: nil,
                    removesChildParagraph: nil,
                    tag: nil,
                    attributes: nil,
                    output:
                        #"<div columns="grid-{{columns}}">{{contents}}</div>"#
                )
            ],
            paragraphStyles: [:]
        )

        let input = #"""
            @Grid(columns: 3) {
                Lorem ipsum
            }
            """#

        let output = renderer.renderHTML(
            markdown: input,
            slug: "",
            assetsPath: "",
            baseURL: ""
        )

        let expectation = #"""
            <div columns="grid-3"><p>Lorem ipsum</p></div>
            """#

        #expect(output == expectation)
    }

    @Test
    func unrecognizedDirective() throws {
        let renderer = MarkdownToHTMLRenderer(
            customBlockDirectives: [
                MarkdownBlockDirective.Mocks.faq()
            ]
        )

        let input = #"""
            @unrecognized {
                Lorem ipsum
            }
            """#

        let output = renderer.renderHTML(
            markdown: input,
            slug: "",
            assetsPath: "",
            baseURL: ""
        )

        #expect(output == "")
    }

    @Test
    func parseError() throws {
        let renderer = MarkdownToHTMLRenderer(
            customBlockDirectives: [
                MarkdownBlockDirective.Mocks.badDirective()
            ]
        )
        let input = #"""
            @BAD(columns: bad, columns: bad) {
                Lorem ipsum 
            }
            """#

        _ = renderer.renderHTML(
            markdown: input,
            slug: "",
            assetsPath: "",
            baseURL: ""
        )
    }

    @Test
    func requiredParameterErrors() throws {
        let renderer = MarkdownToHTMLRenderer(
            customBlockDirectives: [
                MarkdownBlockDirective.Mocks.badDirective()
            ]
        )
        let input = #"""
            @BAD() {
                Lorem ipsum 
            }
            """#

        _ = renderer.renderHTML(
            markdown: input,
            slug: "",
            assetsPath: "",
            baseURL: ""
        )
    }
}
