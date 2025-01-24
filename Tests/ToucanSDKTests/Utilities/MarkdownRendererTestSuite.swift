import Testing
@testable import ToucanSDK

fileprivate extension MarkdownRenderer {

    static var test: MarkdownRenderer {
        .init(
            blockDirectives: [],
            delegate: nil,
            logger: .init(
                label: "test"
            )
        )
    }
}

@Suite
struct MarkdownRendererTestSuite {

    // MARK: - standard elements

    @Test
    func paragraphElement() throws {

        let input = #"""
            Lorem ipsum dolor sit amet.
            """#

        let renderer = MarkdownRenderer.test
        let output = renderer.renderHTML(markdown: input)

        let expectation = #"""
            <p>Lorem ipsum dolor sit amet.</p>
            """#

        #expect(output == expectation)
    }

    @Test
    func lineBreakElement() throws {

        let input = #"""
            This is the first line.
            And this is the second line.
            """#

        let renderer = MarkdownRenderer.test
        let output = renderer.renderHTML(markdown: input)

        let expectation = #"""
            <p>This is the first line.<br>And this is the second line.</p>
            """#

        #expect(output == expectation)
    }

    @Test
    func horizontalRuleElement() throws {

        let input = #"""
            Lorem ipsum
            ***
            dolor
            ---
            sit
            _________________
            amet.
            """#

        let renderer = MarkdownRenderer.test
        let output = renderer.renderHTML(markdown: input)

        let expectation = #"""
            <p>Lorem ipsum</p><hr><h2 id="dolor">dolor</h2><p>sit</p><hr><p>amet.</p>
            """#

        #expect(output == expectation)
    }

    @Test
    func strongElement() throws {

        let input = #"""
            Lorem **ipsum** dolor __sit__ amet.
            """#

        let renderer = MarkdownRenderer.test
        let output = renderer.renderHTML(markdown: input)

        let expectation = #"""
            <p>Lorem <strong>ipsum</strong> dolor <strong>sit</strong> amet.</p>
            """#

        #expect(output == expectation)
    }

    @Test
    func blockquoteElement() throws {

        let input = #"""
            > Lorem ipsum dolor sit amet.
            """#

        let renderer = MarkdownRenderer.test
        let output = renderer.renderHTML(markdown: input)

        let expectation = #"""
            <blockquote><p>Lorem ipsum dolor sit amet.</p></blockquote>
            """#

        #expect(output == expectation)
    }

    @Test
    func nestedBlockquoteElement() throws {

        let input = #"""
            > Lorem ipsum
            >
            >> dolor __sit__ amet.
            """#

        let renderer = MarkdownRenderer.test
        let output = renderer.renderHTML(markdown: input)

        let expectation = #"""
            <blockquote><p>Lorem ipsum</p><blockquote><p>dolor <strong>sit</strong> amet.</p></blockquote></blockquote>
            """#

        #expect(output == expectation)
    }

    @Test
    func emphasisElement() throws {

        let input = #"""
            Lorem *ipsum* dolor _sit_ amet.
            """#

        let renderer = MarkdownRenderer.test
        let output = renderer.renderHTML(markdown: input)

        let expectation = #"""
            <p>Lorem <em>ipsum</em> dolor <em>sit</em> amet.</p>
            """#

        #expect(output == expectation)
    }

    // MARK: - headings

    @Test
    func h1Element() throws {

        let input = #"""
            # Lorem ipsum dolor sit amet.
            """#

        let renderer = MarkdownRenderer.test
        let output = renderer.renderHTML(markdown: input)

        let expectation = #"""
            <h1>Lorem ipsum dolor sit amet.</h1>
            """#

        #expect(output == expectation)
    }

    @Test
    func h2Element() throws {

        let input = #"""
            ## Lorem ipsum dolor sit amet.
            """#

        let renderer = MarkdownRenderer.test
        let output = renderer.renderHTML(markdown: input)

        let expectation = #"""
            <h2 id="lorem-ipsum-dolor-sit-amet.">Lorem ipsum dolor sit amet.</h2>
            """#

        #expect(output == expectation)
    }

    @Test
    func h3Element() throws {

        let input = #"""
            ### Lorem ipsum dolor sit amet.
            """#

        let renderer = MarkdownRenderer.test
        let output = renderer.renderHTML(markdown: input)

        let expectation = #"""
            <h3 id="lorem-ipsum-dolor-sit-amet.">Lorem ipsum dolor sit amet.</h3>
            """#

        #expect(output == expectation)
    }

    @Test
    func h4Element() throws {

        let input = #"""
            #### Lorem ipsum dolor sit amet.
            """#

        let renderer = MarkdownRenderer.test
        let output = renderer.renderHTML(markdown: input)

        let expectation = #"""
            <h4>Lorem ipsum dolor sit amet.</h4>
            """#

        #expect(output == expectation)
    }

    @Test
    func h5Element() throws {

        let input = #"""
            ##### Lorem ipsum dolor sit amet.
            """#

        let renderer = MarkdownRenderer.test
        let output = renderer.renderHTML(markdown: input)

        let expectation = #"""
            <h5>Lorem ipsum dolor sit amet.</h5>
            """#

        #expect(output == expectation)
    }

    @Test
    func h6Element() throws {

        let input = #"""
            ###### Lorem ipsum dolor sit amet.
            """#

        let renderer = MarkdownRenderer.test
        let output = renderer.renderHTML(markdown: input)

        let expectation = #"""
            <h6>Lorem ipsum dolor sit amet.</h6>
            """#

        #expect(output == expectation)
    }

    @Test
    func invalidHeadingElement() throws {

        /// NOTE: this should be treated as a paragraph
        let input = #"""
            ####### Lorem ipsum dolor sit amet.
            """#

        let renderer = MarkdownRenderer.test
        let output = renderer.renderHTML(markdown: input)

        let expectation = #"""
            <p>####### Lorem ipsum dolor sit amet.</p>
            """#

        #expect(output == expectation)
    }

    // MARK: - lists

    @Test
    func unorderedList() throws {

        let input = #"""
            - foo
            - bar
            - baz
            """#

        let renderer = MarkdownRenderer.test
        let output = renderer.renderHTML(markdown: input)

        let expectation = #"""
            <ul><li>foo</li><li>bar</li><li>baz</li></ul>
            """#

        #expect(output == expectation)
    }

    @Test
    func orderedList() throws {

        let input = #"""
            1. foo
            2. bar
            3. baz
            """#

        let renderer = MarkdownRenderer.test
        let output = renderer.renderHTML(markdown: input)

        let expectation = #"""
            <ol><li>foo</li><li>bar</li><li>baz</li></ol>
            """#

        #expect(output == expectation)
    }

    @Test
    func listWithCode() throws {

        let input = #"""
            - foo `aaa`
            - bar
            - baz
            """#

        let renderer = MarkdownRenderer.test
        let output = renderer.renderHTML(markdown: input)

        let expectation = #"""
            <ul><li>foo <code>aaa</code></li><li>bar</li><li>baz</li></ul>
            """#

        #expect(output == expectation)
    }

    // MARK: - other elements

    @Test
    func inlineCode() throws {

        let input = #"""
            Lorem `ipsum dolor` sit amet.
            """#

        let renderer = MarkdownRenderer.test
        let output = renderer.renderHTML(markdown: input)

        let expectation = #"""
            <p>Lorem <code>ipsum dolor</code> sit amet.</p>
            """#

        #expect(output == expectation)
    }

    @Test
    func codeBlockElement() throws {

        let input = #"""
            ```js
            Lorem
            ipsum
            dolor
            sit
            amet
            ```
            """#

        let renderer = MarkdownRenderer.test
        let output = renderer.renderHTML(markdown: input)

        let expectation = #"""
            <pre><code class="language-js">Lorem
            ipsum
            dolor
            sit
            amet
            </code></pre>
            """#

        #expect(output == expectation)
    }

    @Test
    func imageElement() throws {

        let input = #"""
            ![Lorem](lorem.jpg)
            """#

        let renderer = MarkdownRenderer.test
        let output = renderer.renderHTML(markdown: input)

        let expectation = #"""
            <p><img src="lorem.jpg" alt="Lorem"></p>
            """#

        #expect(output == expectation)
    }

    @Test
    func linkElement() throws {

        let input = #"""
            [Swift](https://swift.org/)
            """#

        let renderer = MarkdownRenderer.test
        let output = renderer.renderHTML(markdown: input)

        let expectation = #"""
            <p><a href="https://swift.org/">Swift</a></p>
            """#

        #expect(output == expectation)
    }

    @Test
    func inlineHTML() throws {

        let input = #"""
            <b>https://swift.org</b>
            """#

        let renderer = MarkdownRenderer.test
        let output = renderer.renderHTML(markdown: input)

        let expectation = #"""
            <p><b>https://swift.org</b></p>
            """#

        #expect(output == expectation)
    }

    @Test
    func lineBreak() throws {

        let input = #"""
            a\
            b
            """#

        let renderer = MarkdownRenderer.test
        let output = renderer.renderHTML(markdown: input)

        let expectation = #"""
            <p>a<br>b</p>
            """#

        #expect(output == expectation)
    }

}
