//
//  File.swift
//
//
//  Created by Tibor Bodecs on 03/05/2024.
//

import XCTest
@testable import ToucanSDK

final class MarkdownToHTMLRendererTestSuite: XCTest {

    // MARK: - standard elements

    func testParagraphElement() throws {

        let input = #"""
            Lorem ipsum dolor sit amet.
            """#

        let renderer = MarkdownToHTMLRenderer()
        let output = renderer.render(markdown: input)

        let expectation = #"""
            <p>Lorem ipsum dolor sit amet.</p>
            """#

        XCTAssert(output == expectation)
    }

    func testLineBreakElement() throws {

        let input = #"""
            This is the first line.
            And this is the second line.
            """#

        let renderer = MarkdownToHTMLRenderer()
        let output = renderer.render(markdown: input)

        let expectation = #"""
            <p>This is the first line.<br>And this is the second line.</p>
            """#

        XCTAssert(output == expectation)
    }

    func testHorizontalRuleElement() throws {

        let input = #"""
            Lorem ipsum
            ***
            dolor
            ---
            sit
            _________________
            amet.
            """#

        let renderer = MarkdownToHTMLRenderer()
        let output = renderer.render(markdown: input)

        let expectation = #"""
            <p>Lorem ipsum</p><hr><h2 id="dolor">dolor</h2><p>sit</p><hr><p>amet.</p>
            """#

        XCTAssert(output == expectation)
    }

    func testStrongElement() throws {

        let input = #"""
            Lorem **ipsum** dolor __sit__ amet.
            """#

        let renderer = MarkdownToHTMLRenderer()
        let output = renderer.render(markdown: input)

        let expectation = #"""
            <p>Lorem <strong>ipsum</strong> dolor <strong>sit</strong> amet.</p>
            """#

        XCTAssert(output == expectation)
    }

    func testBlockquoteElement() throws {

        let input = #"""
            > Lorem ipsum dolor sit amet.
            """#

        let renderer = MarkdownToHTMLRenderer()
        let output = renderer.render(markdown: input)

        let expectation = #"""
            <blockquote><p>Lorem ipsum dolor sit amet.</p></blockquote>
            """#

        XCTAssert(output == expectation)
    }

    func testNestedBlockquoteElement() throws {

        let input = #"""
            > Lorem ipsum
            >
            >> dolor __sit__ amet.
            """#

        let renderer = MarkdownToHTMLRenderer()
        let output = renderer.render(markdown: input)

        let expectation = #"""
            <blockquote><p>Lorem ipsum</p><blockquote><p>dolor <strong>sit</strong> amet.</p></blockquote></blockquote>
            """#

        XCTAssert(output == expectation)
    }

    func testEmphasisElement() throws {

        let input = #"""
            Lorem *ipsum* dolor _sit_ amet.
            """#

        let renderer = MarkdownToHTMLRenderer()
        let output = renderer.render(markdown: input)

        let expectation = #"""
            <p>Lorem <em>ipsum</em> dolor <em>sit</em> amet.</p>
            """#

        XCTAssert(output == expectation)
    }

    // MARK: - headings

    func testH1Element() throws {

        let input = #"""
            # Lorem ipsum dolor sit amet.
            """#

        let renderer = MarkdownToHTMLRenderer()
        let output = renderer.render(markdown: input)

        let expectation = #"""
            <h1>Lorem ipsum dolor sit amet.</h1>
            """#

        XCTAssert(output == expectation)
    }

    func testH2Element() throws {

        let input = #"""
            ## Lorem ipsum dolor sit amet.
            """#

        let renderer = MarkdownToHTMLRenderer()
        let output = renderer.render(markdown: input)

        let expectation = #"""
            <h2 id="lorem-ipsum-dolor-sit-amet.">Lorem ipsum dolor sit amet.</h2>
            """#

        XCTAssert(output == expectation)
    }

    func testH3Element() throws {

        let input = #"""
            ### Lorem ipsum dolor sit amet.
            """#

        let renderer = MarkdownToHTMLRenderer()
        let output = renderer.render(markdown: input)

        let expectation = #"""
            <h3 id="lorem-ipsum-dolor-sit-amet.">Lorem ipsum dolor sit amet.</h3>
            """#

        XCTAssert(output == expectation)
    }

    func testH4Element() throws {

        let input = #"""
            #### Lorem ipsum dolor sit amet.
            """#

        let renderer = MarkdownToHTMLRenderer()
        let output = renderer.render(markdown: input)

        let expectation = #"""
            <h4>Lorem ipsum dolor sit amet.</h4>
            """#

        XCTAssert(output == expectation)
    }

    func testH5Element() throws {

        let input = #"""
            ##### Lorem ipsum dolor sit amet.
            """#

        let renderer = MarkdownToHTMLRenderer()
        let output = renderer.render(markdown: input)

        let expectation = #"""
            <h5>Lorem ipsum dolor sit amet.</h5>
            """#

        XCTAssert(output == expectation)
    }

    func testH6Element() throws {

        let input = #"""
            ###### Lorem ipsum dolor sit amet.
            """#

        let renderer = MarkdownToHTMLRenderer()
        let output = renderer.render(markdown: input)

        let expectation = #"""
            <h6>Lorem ipsum dolor sit amet.</h6>
            """#

        XCTAssert(output == expectation)
    }

    func testInvalidHeadingElement() throws {

        /// NOTE: this should be treated as a paragraph
        let input = #"""
            ####### Lorem ipsum dolor sit amet.
            """#

        let renderer = MarkdownToHTMLRenderer()
        let output = renderer.render(markdown: input)

        let expectation = #"""
            <p>####### Lorem ipsum dolor sit amet.</p>
            """#

        XCTAssert(output == expectation)
    }

    // MARK: - lists

    func testUnorderedList() throws {

        let input = #"""
            - foo
            - bar
            - baz
            """#

        let renderer = MarkdownToHTMLRenderer()
        let output = renderer.render(markdown: input)

        let expectation = #"""
            <ul><li>foo</li><li>bar</li><li>baz</li></ul>
            """#

        XCTAssert(output == expectation)
    }

    func testOrderedList() throws {

        let input = #"""
            1. foo
            2. bar
            3. baz
            """#

        let renderer = MarkdownToHTMLRenderer()
        let output = renderer.render(markdown: input)

        let expectation = #"""
            <ol><li>foo</li><li>bar</li><li>baz</li></ol>
            """#

        XCTAssert(output == expectation)
    }

    // MARK: - other elements

    func testInlineCode() throws {

        let input = #"""
            Lorem `ipsum dolor` sit amet.
            """#

        let renderer = MarkdownToHTMLRenderer()
        let output = renderer.render(markdown: input)

        let expectation = #"""
            <p>Lorem <code>ipsum dolor</code> sit amet.</p>
            """#

        XCTAssert(output == expectation)
    }

    func testCodeBlockElement() throws {

        let input = #"""
            ```js
            Lorem
            ipsum
            dolor
            sit
            amet
            ```
            """#

        let renderer = MarkdownToHTMLRenderer()
        let output = renderer.render(markdown: input)

        let expectation = #"""
            <pre><code class="language-js">Lorem
            ipsum
            dolor
            sit
            amet
            </code></pre>
            """#

        XCTAssert(output == expectation)
    }

    func testImageElement() throws {

        let input = #"""
            ![Lorem](lorem.jpg)
            """#

        let renderer = MarkdownToHTMLRenderer()
        let output = renderer.render(markdown: input)

        let expectation = #"""
            <p><img src="lorem.jpg" alt="Lorem"></p>
            """#

        XCTAssert(output == expectation)
    }

    func testLinkElement() throws {

        let input = #"""
            [Swift](https://swift.org/)
            """#

        let renderer = MarkdownToHTMLRenderer()
        let output = renderer.render(markdown: input)

        let expectation = #"""
            <p><a href="https://swift.org/">Swift</a></p>
            """#

        XCTAssert(output == expectation)
    }

    func testInlineHTML() throws {

        let input = #"""
            <b>https://swift.org</b>
            """#

        let renderer = MarkdownToHTMLRenderer()
        let output = renderer.render(markdown: input)

        let expectation = #"""
            <p><b>https://swift.org</b></p>
            """#

        XCTAssert(output == expectation)
    }

    func testLineBreak() throws {

        let input = #"""
            a\
            b
            """#

        let renderer = MarkdownToHTMLRenderer()
        let output = renderer.render(markdown: input)

        let expectation = #"""
            <p>a<br>b</p>
            """#

        XCTAssert(output == expectation)
    }

}
