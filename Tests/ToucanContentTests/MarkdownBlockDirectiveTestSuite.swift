//
//  MarkdownBlockDirectiveTestSuite.swift
//  Toucan
//
//  Created by Binary Birds on 2025. 04. 17..

import Testing
import Logging
import ToucanTesting
@testable import ToucanModels
@testable import ToucanContent

@Suite
struct MarkdownBlockDirectiveTestSuite {

    @Test
    func simpleCustomBlockDirective() throws {
        let renderer = MarkdownToHTMLRenderer(
            customBlockDirectives: [
                MarkdownBlockDirective.Mocks.faq()
            ],
            paragraphStyles: ParagraphStyles.defaults
        )

        let input = #"""
            @FAQ {
                Lorem ipsum
            }
            """#

        let output = renderer.renderHTML(
            markdown: input,
            slug: .init(value: ""),
            assetsPath: "",
            baseUrl: ""
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
            paragraphStyles: ParagraphStyles.defaults
        )

        let input = #"""
            @FAQ {
                Lorem ipsum
            }
            """#

        let output = renderer.renderHTML(
            markdown: input,
            slug: .init(value: ""),
            assetsPath: "",
            baseUrl: ""
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
            paragraphStyles: ParagraphStyles.defaults
        )

        let input = #"""
            @Grid(columns: 3) {
                Lorem ipsum
            }
            """#

        let output = renderer.renderHTML(
            markdown: input,
            slug: .init(value: ""),
            assetsPath: "",
            baseUrl: ""
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
            paragraphStyles: ParagraphStyles.defaults
        )

        let input = #"""
            @Grid(columns: 3) {
                Lorem ipsum
            }
            """#

        let output = renderer.renderHTML(
            markdown: input,
            slug: .init(value: ""),
            assetsPath: "",
            baseUrl: ""
        )

        let expectation = #"""
            <div columns="grid-3"><p>Lorem ipsum</p></div>
            """#

        #expect(output == expectation)
    }

    @Test
    func unrecognizedDirective() throws {

        let logging = Logger.inMemory(label: "MarkdownBlockDirectiveTestSuite")
        let renderer = MarkdownToHTMLRenderer(
            customBlockDirectives: [
                MarkdownBlockDirective.Mocks.faq()
            ],
            paragraphStyles: ParagraphStyles.defaults,
            logger: logging.logger
        )

        let input = #"""
            @unrecognized {
                Lorem ipsum
            }
            """#

        let output = renderer.renderHTML(
            markdown: input,
            slug: .init(value: ""),
            assetsPath: "",
            baseUrl: ""
        )

        let results = logging.handler.messages.filter {
            $0.description.contains("Unrecognized block directive")
        }
        #expect(results.count == 1)
        #expect(output == "")
    }

    @Test
    func parseError() throws {

        let logging = Logger.inMemory(
            label: "MarkdownBlockDirectiveTestSuite",
            logLevel: .warning
        )
        let renderer = MarkdownToHTMLRenderer(
            customBlockDirectives: [
                MarkdownBlockDirective.Mocks.badDirective()
            ],
            paragraphStyles: ParagraphStyles.defaults,
            logger: logging.logger
        )
        let input = #"""
            @BAD(columns: bad, columns: bad) {
                Lorem ipsum 
            }
            """#

        _ = renderer.renderHTML(
            markdown: input,
            slug: .init(value: ""),
            assetsPath: "",
            baseUrl: ""
        )
        let results = logging.handler.messages.filter {
            $0.description.contains("duplicateArgument")
        }
        #expect(results.count == 1)
    }

    @Test
    func requiredParameterErrors() throws {

        let logging = Logger.inMemory(
            label: "MarkdownBlockDirectiveTestSuite",
            logLevel: .warning
        )
        let renderer = MarkdownToHTMLRenderer(
            customBlockDirectives: [
                MarkdownBlockDirective.Mocks.badDirective()
            ],
            paragraphStyles: ParagraphStyles.defaults,
            logger: logging.logger
        )
        let input = #"""
            @BAD() {
                Lorem ipsum 
            }
            """#

        _ = renderer.renderHTML(
            markdown: input,
            slug: .init(value: ""),
            assetsPath: "",
            baseUrl: ""
        )

        let results = logging.handler.messages.filter {
            $0.description.contains("require")
        }
        #expect(results.count == 2)
    }

}
