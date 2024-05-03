import XCTest
@testable import Toucan

final class HTMLRendererTests: XCTestCase {

    // MARK: - standard elements

    func testParagraphElement() throws {

        let input = #"""
            Lorem ipsum dolor sit amet.
            """#

        let renderer = HTMLRenderer()
        let output = renderer.render(markdown: input)

        let expectation = #"""
            <p>Lorem ipsum dolor sit amet.</p>
            """#

        XCTAssertEqual(output, expectation)
    }

    func testLineBreakElement() throws {

        let input = #"""
            This is the first line.
            And this is the second line.
            """#

        let renderer = HTMLRenderer()
        let output = renderer.render(markdown: input)

        let expectation = #"""
            <p>This is the first line.<br>And this is the second line.</p>
            """#

        XCTAssertEqual(output, expectation)
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

        let renderer = HTMLRenderer()
        let output = renderer.render(markdown: input)

        let expectation = #"""
            <p>Lorem ipsum</p><hr><h2>dolor</h2><p>sit</p><hr><p>amet.</p>
            """#

        XCTAssertEqual(output, expectation)
    }

    func testStrongElement() throws {

        let input = #"""
            Lorem **ipsum** dolor __sit__ amet.
            """#

        let renderer = HTMLRenderer()
        let output = renderer.render(markdown: input)

        let expectation = #"""
            <p>Lorem <strong>ipsum</strong> dolor <strong>sit</strong> amet.</p>
            """#

        XCTAssertEqual(output, expectation)
    }

    func testBlockquoteElement() throws {

        let input = #"""
            > Lorem ipsum dolor sit amet.
            """#

        let renderer = HTMLRenderer()
        let output = renderer.render(markdown: input)

        let expectation = #"""
            <blockquote><p>Lorem ipsum dolor sit amet.</p></blockquote>
            """#

        XCTAssertEqual(output, expectation)
    }

    func testNestedBlockquoteElement() throws {

        let input = #"""
            > Lorem ipsum
            >
            >> dolor __sit__ amet.
            """#

        let renderer = HTMLRenderer()
        let output = renderer.render(markdown: input)

        let expectation = #"""
            <blockquote><p>Lorem ipsum</p><blockquote><p>dolor <strong>sit</strong> amet.</p></blockquote></blockquote>
            """#

        XCTAssertEqual(output, expectation)
    }

    func testEmphasisElement() throws {

        let input = #"""
            Lorem *ipsum* dolor _sit_ amet.
            """#

        let renderer = HTMLRenderer()
        let output = renderer.render(markdown: input)

        let expectation = #"""
            <p>Lorem <em>ipsum</em> dolor <em>sit</em> amet.</p>
            """#

        XCTAssertEqual(output, expectation)
    }

    // MARK: - headings

    func testH1Element() throws {

        let input = #"""
            # Lorem ipsum dolor sit amet.
            """#

        let renderer = HTMLRenderer()
        let output = renderer.render(markdown: input)

        let expectation = #"""
            <h1>Lorem ipsum dolor sit amet.</h1>
            """#

        XCTAssertEqual(output, expectation)
    }

    func testH2Element() throws {

        let input = #"""
            ## Lorem ipsum dolor sit amet.
            """#

        let renderer = HTMLRenderer()
        let output = renderer.render(markdown: input)

        let expectation = #"""
            <h2>Lorem ipsum dolor sit amet.</h2>
            """#

        XCTAssertEqual(output, expectation)
    }

    func testH3Element() throws {

        let input = #"""
            ### Lorem ipsum dolor sit amet.
            """#

        let renderer = HTMLRenderer()
        let output = renderer.render(markdown: input)

        let expectation = #"""
            <h3>Lorem ipsum dolor sit amet.</h3>
            """#

        XCTAssertEqual(output, expectation)
    }

    func testH4Element() throws {

        let input = #"""
            #### Lorem ipsum dolor sit amet.
            """#

        let renderer = HTMLRenderer()
        let output = renderer.render(markdown: input)

        let expectation = #"""
            <h4>Lorem ipsum dolor sit amet.</h4>
            """#

        XCTAssertEqual(output, expectation)
    }

    func testH5Element() throws {

        let input = #"""
            ##### Lorem ipsum dolor sit amet.
            """#

        let renderer = HTMLRenderer()
        let output = renderer.render(markdown: input)

        let expectation = #"""
            <h5>Lorem ipsum dolor sit amet.</h5>
            """#

        XCTAssertEqual(output, expectation)
    }

    func testH6Element() throws {

        let input = #"""
            ###### Lorem ipsum dolor sit amet.
            """#

        let renderer = HTMLRenderer()
        let output = renderer.render(markdown: input)

        let expectation = #"""
            <h6>Lorem ipsum dolor sit amet.</h6>
            """#

        XCTAssertEqual(output, expectation)
    }

    func testInvalidHeadingElement() throws {

        /// NOTE: this should be treated as a paragraph
        let input = #"""
            ####### Lorem ipsum dolor sit amet.
            """#

        let renderer = HTMLRenderer()
        let output = renderer.render(markdown: input)

        let expectation = #"""
            <p>####### Lorem ipsum dolor sit amet.</p>
            """#

        XCTAssertEqual(output, expectation)
    }

    // MARK: - lists

    func testUnorderedList() throws {

        let input = #"""
            - foo
            - bar
            - baz
            """#

        let renderer = HTMLRenderer()
        let output = renderer.render(markdown: input)

        let expectation = #"""
            <ul><li>foo</li><li>bar</li><li>baz</li></ul>
            """#

        XCTAssertEqual(output, expectation)
    }

    func testOrderedList() throws {

        let input = #"""
            1. foo
            2. bar
            3. baz
            """#

        let renderer = HTMLRenderer()
        let output = renderer.render(markdown: input)

        let expectation = #"""
            <ol><li>foo</li><li>bar</li><li>baz</li></ol>
            """#

        XCTAssertEqual(output, expectation)
    }

    // MARK: - other elements

    func testInlineCode() throws {

        let input = #"""
            Lorem `ipsum dolor` sit amet.
            """#

        let renderer = HTMLRenderer()
        let output = renderer.render(markdown: input)

        let expectation = #"""
            <p>Lorem <code>ipsum dolor</code> sit amet.</p>
            """#

        XCTAssertEqual(output, expectation)
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

        let renderer = HTMLRenderer()
        let output = renderer.render(markdown: input)

        let expectation = #"""
            <pre><code class="language-js">Lorem
            ipsum
            dolor
            sit
            amet
            </code></pre>
            """#

        XCTAssertEqual(output, expectation)
    }

    func testImageElement() throws {

        let input = #"""
            ![Lorem](lorem.jpg)
            """#

        let renderer = HTMLRenderer()
        let output = renderer.render(markdown: input)

        let expectation = #"""
            <p><img src="lorem.jpg" alt="Lorem"></p>
            """#

        XCTAssertEqual(output, expectation)
    }

    func testLinkElement() throws {

        let input = #"""
            [Swift](https://swift.org/)
            """#

        let renderer = HTMLRenderer()
        let output = renderer.render(markdown: input)

        let expectation = #"""
            <p><a href="https://swift.org/">Swift</a></p>
            """#

        XCTAssertEqual(output, expectation)
    }

    func testInlineHTML() throws {

        let input = #"""
            <b>https://swift.org</b>
            """#

        let renderer = HTMLRenderer()
        let output = renderer.render(markdown: input)

        let expectation = #"""
            <p><b>https://swift.org</b></p>
            """#

        XCTAssertEqual(output, expectation)
    }

    func testLineBreak() throws {

        let input = #"""
            a\
            b
            """#

        let renderer = HTMLRenderer()
        let output = renderer.render(markdown: input)

        let expectation = #"""
            <p>a<br>b</p>
            """#

        XCTAssertEqual(output, expectation)
    }

}
