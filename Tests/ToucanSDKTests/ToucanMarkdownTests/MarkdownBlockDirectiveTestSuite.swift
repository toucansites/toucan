//
//  MarkdownBlockDirectiveTestSuite.swift
//  Toucan
//
//  Created by Binary Birds on 2025. 04. 17..

import Logging
import Testing
import ToucanSource

@testable import ToucanSDK

@Suite
struct MarkdownBlockDirectiveTestSuite {
    @Test
    func simpleCustomBlockDirective() throws {
        let renderer = MarkdownToHTMLRenderer(
            customBlockDirectives: [
                Mocks.Blocks.faq()
            ],
            paragraphStyles: [:],
            codeBlockLanguagePrefix: ""
        )

        let input = #"""
            @FAQ {
                Lorem ipsum
            }
            """#

        let output = try renderer.renderHTML(
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
                Mocks.Blocks.faq()
            ],
            paragraphStyles: [:],
            codeBlockLanguagePrefix: ""
        )

        let input = #"""
            @FAQ {
                Lorem ipsum
            }
            """#

        let output = try renderer.renderHTML(
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
                Mocks.Blocks.grid()
            ],
            paragraphStyles: [:],
            codeBlockLanguagePrefix: ""
        )

        let input = #"""
            @Grid(columns: 3) {
                Lorem ipsum
            }
            """#

        let output = try renderer.renderHTML(
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
                Mocks.Blocks.grid()
            ],
            paragraphStyles: [:],
            codeBlockLanguagePrefix: ""
        )

        let input = #"""
            @Grid(columns: 3) {
                Lorem ipsum
            }
            """#

        let output = try renderer.renderHTML(
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
                Mocks.Blocks.faq()
            ],
            codeBlockLanguagePrefix: ""
        )

        let input = #"""
            @unrecognized {
                Lorem ipsum
            }
            """#

        let output = try renderer.renderHTML(
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
                Mocks.Blocks.badDirective()
            ],
            codeBlockLanguagePrefix: ""
        )
        let input = #"""
            @BAD(columns: bad, columns: bad) {
                Lorem ipsum 
            }
            """#

        _ = try renderer.renderHTML(
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
                Mocks.Blocks.badDirective()
            ],
            codeBlockLanguagePrefix: ""
        )
        let input = #"""
            @BAD() {
                Lorem ipsum 
            }
            """#

        _ = try renderer.renderHTML(
            markdown: input,
            slug: "",
            assetsPath: "",
            baseURL: ""
        )
    }
}
