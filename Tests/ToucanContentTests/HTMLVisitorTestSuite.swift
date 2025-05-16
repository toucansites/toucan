//
//  HTMLVisitorTestSuite.swift
//  Toucan
//
//  Created by Binary Birds on 2025. 04. 15..

import Testing
import Markdown
import Logging
@testable import ToucanContent
@testable import ToucanModels

@Suite
struct HTMLVisitorTestSuite {

    func renderHTML(
        baseUrl: String,
        markdown: String
    ) -> String {
        let logger = Logger(label: "HTMLVisitorTestSuite")
        let document = Document(
            parsing: markdown,
            options: []
        )

        var visitor = HTMLVisitor(
            blockDirectives: [],
            paragraphStyles: ParagraphStyles.defaults.styles,
            logger: logger,
            slug: "slug",
            assetsPath: "assets",
            baseUrl: baseUrl
        )

        return visitor.visit(document)
    }

    // MARK: - standard elements

    @Test("", arguments: ["http://localhost:3000", "http://localhost:3000/"])
    func inlineHTML(baseUrl: String) {

        let input = #"""
            <b>https://swift.org</b>
            """#

        let output = renderHTML(baseUrl: baseUrl, markdown: input)

        let expectation = #"""
            <p><b>https://swift.org</b></p>
            """#

        #expect(output == expectation)
    }

    @Test("", arguments: ["http://localhost:3000", "http://localhost:3000/"])
    func paragraph(baseUrl: String) {

        let input = #"""
            Lorem ipsum dolor sit amet.
            """#

        let output = renderHTML(baseUrl: baseUrl, markdown: input)

        let expectation = #"""
            <p>Lorem ipsum dolor sit amet.</p>
            """#

        #expect(output == expectation)
    }

    @Test("", arguments: ["http://localhost:3000", "http://localhost:3000/"])
    func softBreak(baseUrl: String) {

        let input = #"""
            This is the first line.
            And this is the second line.
            """#

        let output = renderHTML(baseUrl: baseUrl, markdown: input)

        let expectation = #"""
            <p>This is the first line.<br>And this is the second line.</p>
            """#

        #expect(output == expectation)
    }

    @Test("", arguments: ["http://localhost:3000", "http://localhost:3000/"])
    func lineBreak(baseUrl: String) {

        let input = #"""
            a\
            b
            """#

        let output = renderHTML(baseUrl: baseUrl, markdown: input)

        let expectation = #"""
            <p>a<br>b</p>
            """#

        #expect(output == expectation)
    }

    @Test("", arguments: ["http://localhost:3000", "http://localhost:3000/"])
    func thematicBreak(baseUrl: String) {

        let input = #"""
            Lorem ipsum
            ***
            dolor
            ---
            sit
            _________________
            amet.
            """#

        let output = renderHTML(baseUrl: baseUrl, markdown: input)

        let expectation = #"""
            <p>Lorem ipsum</p><hr><h2 id="dolor">dolor</h2><p>sit</p><hr><p>amet.</p>
            """#

        #expect(output == expectation)
    }

    @Test("", arguments: ["http://localhost:3000", "http://localhost:3000/"])
    func strong(baseUrl: String) {

        let input = #"""
            Lorem **ipsum** dolor __sit__ amet.
            """#

        let output = renderHTML(baseUrl: baseUrl, markdown: input)

        let expectation = #"""
            <p>Lorem <strong>ipsum</strong> dolor <strong>sit</strong> amet.</p>
            """#

        #expect(output == expectation)
    }

    @Test("", arguments: ["http://localhost:3000", "http://localhost:3000/"])
    func striketrough(baseUrl: String) {

        let input = #"""
            Lorem ipsum ~~dolor sit amet~~.
            """#

        let output = renderHTML(baseUrl: baseUrl, markdown: input)

        let expectation = #"""
            <p>Lorem ipsum <s>dolor sit amet</s>.</p>
            """#

        #expect(output == expectation)
    }

    @Test("", arguments: ["http://localhost:3000", "http://localhost:3000/"])
    func blockquote(baseUrl: String) {

        let input = #"""
            > Lorem ipsum dolor sit amet.
            """#

        let output = renderHTML(baseUrl: baseUrl, markdown: input)

        let expectation = #"""
            <blockquote><p>Lorem ipsum dolor sit amet.</p></blockquote>
            """#

        #expect(output == expectation)
    }

    @Test("", arguments: ["http://localhost:3000", "http://localhost:3000/"])
    func blockquoteNote(baseUrl: String) {

        let input = #"""
            > NOTE: Lorem ipsum dolor sit amet.
            """#

        let output = renderHTML(baseUrl: baseUrl, markdown: input)

        let expectation = #"""
            <blockquote class="note"><p>Lorem ipsum dolor sit amet.</p></blockquote>
            """#

        #expect(output == expectation)
    }

    @Test("", arguments: ["http://localhost:3000", "http://localhost:3000/"])
    func blockquoteWarn(baseUrl: String) {

        let input = #"""
            > WARN: Lorem ipsum dolor sit amet.
            """#

        let output = renderHTML(baseUrl: baseUrl, markdown: input)

        let expectation = #"""
            <blockquote class="warning"><p>Lorem ipsum dolor sit amet.</p></blockquote>
            """#

        #expect(output == expectation)
    }

    @Test("", arguments: ["http://localhost:3000", "http://localhost:3000/"])
    func blockquoteWarning(baseUrl: String) {

        let input = #"""
            > warning: Lorem ipsum dolor sit amet.
            """#

        let output = renderHTML(baseUrl: baseUrl, markdown: input)

        let expectation = #"""
            <blockquote class="warning"><p>Lorem ipsum dolor sit amet.</p></blockquote>
            """#

        #expect(output == expectation)
    }

    @Test("", arguments: ["http://localhost:3000", "http://localhost:3000/"])
    func nestedBlockquote(baseUrl: String) {

        let input = #"""
            > Lorem ipsum
            >
            >> dolor __sit__ amet.
            """#

        let output = renderHTML(baseUrl: baseUrl, markdown: input)

        let expectation = #"""
            <blockquote><p>Lorem ipsum</p><blockquote><p>dolor <strong>sit</strong> amet.</p></blockquote></blockquote>
            """#

        #expect(output == expectation)
    }

    @Test("", arguments: ["http://localhost:3000", "http://localhost:3000/"])
    func emphasis(baseUrl: String) {

        let input = #"""
            Lorem *ipsum* dolor _sit_ amet.
            """#

        let output = renderHTML(baseUrl: baseUrl, markdown: input)

        let expectation = #"""
            <p>Lorem <em>ipsum</em> dolor <em>sit</em> amet.</p>
            """#

        #expect(output == expectation)
    }

    // MARK: - headings

    @Test("", arguments: ["http://localhost:3000", "http://localhost:3000/"])
    func h1(baseUrl: String) {

        let input = #"""
            # Lorem ipsum dolor sit amet.
            """#

        let output = renderHTML(baseUrl: baseUrl, markdown: input)

        let expectation = #"""
            <h1>Lorem ipsum dolor sit amet.</h1>
            """#

        #expect(output == expectation)
    }

    @Test("", arguments: ["http://localhost:3000", "http://localhost:3000/"])
    func h2(baseUrl: String) {

        let input = #"""
            ## Lorem ipsum dolor sit amet.
            """#

        let output = renderHTML(baseUrl: baseUrl, markdown: input)

        let expectation = #"""
            <h2 id="lorem-ipsum-dolor-sit-amet.">Lorem ipsum dolor sit amet.</h2>
            """#

        #expect(output == expectation)
    }

    @Test("", arguments: ["http://localhost:3000", "http://localhost:3000/"])
    func h3(baseUrl: String) {

        let input = #"""
            ### Lorem ipsum dolor sit amet.
            """#

        let output = renderHTML(baseUrl: baseUrl, markdown: input)

        let expectation = #"""
            <h3 id="lorem-ipsum-dolor-sit-amet.">Lorem ipsum dolor sit amet.</h3>
            """#

        #expect(output == expectation)
    }

    @Test("", arguments: ["http://localhost:3000", "http://localhost:3000/"])
    func h4(baseUrl: String) {

        let input = #"""
            #### Lorem ipsum dolor sit amet.
            """#

        let output = renderHTML(baseUrl: baseUrl, markdown: input)

        let expectation = #"""
            <h4>Lorem ipsum dolor sit amet.</h4>
            """#

        #expect(output == expectation)
    }

    @Test("", arguments: ["http://localhost:3000", "http://localhost:3000/"])
    func h5(baseUrl: String) {

        let input = #"""
            ##### Lorem ipsum dolor sit amet.
            """#

        let output = renderHTML(baseUrl: baseUrl, markdown: input)

        let expectation = #"""
            <h5>Lorem ipsum dolor sit amet.</h5>
            """#

        #expect(output == expectation)
    }

    @Test("", arguments: ["http://localhost:3000", "http://localhost:3000/"])
    func h6(baseUrl: String) {

        let input = #"""
            ###### Lorem ipsum dolor sit amet.
            """#

        let output = renderHTML(baseUrl: baseUrl, markdown: input)

        let expectation = #"""
            <h6>Lorem ipsum dolor sit amet.</h6>
            """#

        #expect(output == expectation)
    }

    @Test("", arguments: ["http://localhost:3000", "http://localhost:3000/"])
    func invalidHeading(baseUrl: String) {

        /// NOTE: this should be treated as a paragraph
        let input = #"""
            ####### Lorem ipsum dolor sit amet.
            """#

        let output = renderHTML(baseUrl: baseUrl, markdown: input)

        let expectation = #"""
            <p>####### Lorem ipsum dolor sit amet.</p>
            """#

        #expect(output == expectation)
    }

    // MARK: - lists

    @Test("", arguments: ["http://localhost:3000", "http://localhost:3000/"])
    func unorderedList(baseUrl: String) {

        let input = #"""
            - foo
            - bar
            - baz
            """#

        let output = renderHTML(baseUrl: baseUrl, markdown: input)

        let expectation = #"""
            <ul><li>foo</li><li>bar</li><li>baz</li></ul>
            """#

        #expect(output == expectation)
    }

    @Test("", arguments: ["http://localhost:3000", "http://localhost:3000/"])
    func orderedList(baseUrl: String) {

        let input = #"""
            1. foo
            2. bar
            3. baz
            """#

        let output = renderHTML(baseUrl: baseUrl, markdown: input)

        let expectation = #"""
            <ol><li>foo</li><li>bar</li><li>baz</li></ol>
            """#

        #expect(output == expectation)
    }

    @Test("", arguments: ["http://localhost:3000", "http://localhost:3000/"])
    func listWithCode(baseUrl: String) {

        let input = #"""
            - foo `aaa`
            - bar
            - baz
            """#

        let output = renderHTML(baseUrl: baseUrl, markdown: input)

        let expectation = #"""
            <ul><li>foo <code>aaa</code></li><li>bar</li><li>baz</li></ul>
            """#

        #expect(output == expectation)
    }

    // MARK: - other elements

    @Test("", arguments: ["http://localhost:3000", "http://localhost:3000/"])
    func inlineCode(baseUrl: String) {

        let input = #"""
            Lorem `ipsum dolor` sit amet.
            """#

        let output = renderHTML(baseUrl: baseUrl, markdown: input)

        let expectation = #"""
            <p>Lorem <code>ipsum dolor</code> sit amet.</p>
            """#

        #expect(output == expectation)
    }

    @Test("", arguments: ["http://localhost:3000", "http://localhost:3000/"])
    func link(baseUrl: String) {

        let input = #"""
            [Swift](https://swift.org/)
            """#

        let output = renderHTML(baseUrl: baseUrl, markdown: input)

        let expectation = #"""
            <p><a href="https://swift.org/" target="_blank">Swift</a></p>
            """#

        #expect(output == expectation)
    }

    @Test("", arguments: ["http://localhost:3000", "http://localhost:3000/"])
    func emptyLink(baseUrl: String) {

        let input = #"""
            [Swift]()
            """#

        let output = renderHTML(baseUrl: baseUrl, markdown: input)

        let expectation = #"""
            <p><a>Swift</a></p>
            """#

        #expect(output == expectation)
    }

    @Test("", arguments: ["http://localhost:3000", "http://localhost:3000/"])
    func dotLink(baseUrl: String) {

        let input = #"""
            [Swift](./foo)
            """#

        let output = renderHTML(baseUrl: baseUrl, markdown: input)

        let expectation = #"""
            <p><a href="./foo">Swift</a></p>
            """#

        #expect(output == expectation)
    }

    @Test("", arguments: ["http://localhost:3000", "http://localhost:3000/"])
    func slashLink(baseUrl: String) {

        let input = #"""
            [Swift](/foo)
            """#

        let output = renderHTML(baseUrl: baseUrl, markdown: input)

        let expectation = #"""
            <p><a href="http://localhost:3000/foo">Swift</a></p>
            """#

        #expect(output == expectation)
    }

    @Test("", arguments: ["http://localhost:3000", "http://localhost:3000/"])
    func externalLink(baseUrl: String) {

        let input = #"""
            [Swift](foo/bar)
            """#

        let output = renderHTML(baseUrl: baseUrl, markdown: input)

        let expectation = #"""
            <p><a href="foo/bar" target="_blank">Swift</a></p>
            """#

        #expect(output == expectation)
    }

    @Test("", arguments: ["http://localhost:3000", "http://localhost:3000/"])
    func anchorLink(baseUrl: String) {

        let input = #"""
            [Swift](#anchor)
            """#

        let output = renderHTML(baseUrl: baseUrl, markdown: input)

        let expectation = #"""
            <p><a href="#anchor">Swift</a></p>
            """#

        #expect(output == expectation)
    }

    @Test("", arguments: ["http://localhost:3000", "http://localhost:3000/"])
    func anchorName(baseUrl: String) {

        let input = #"""
            [Swift](#[name]anchor)
            """#

        let output = renderHTML(baseUrl: baseUrl, markdown: input)

        let expectation = #"""
            <p><a name="anchor">Swift</a></p>
            """#

        #expect(output == expectation)
    }

    @Test("", arguments: ["http://localhost:3000", "http://localhost:3000/"])
    func image(baseUrl: String) {

        let input = #"""
            ![Lorem](lorem.jpg)
            """#

        let output = renderHTML(baseUrl: baseUrl, markdown: input)

        let expectation = #"""
            <p><img src="lorem.jpg" alt="Lorem"></p>
            """#

        #expect(output == expectation)
    }

    @Test("", arguments: ["http://localhost:3000", "http://localhost:3000/"])
    func imageAssetsPrefix(baseUrl: String) {

        let input = #"""
            ![Lorem](./assets/lorem.jpg)
            """#

        let output = renderHTML(baseUrl: baseUrl, markdown: input)

        let expectation = #"""
            <p><img src="http://localhost:3000/assets/slug/lorem.jpg" alt="Lorem"></p>
            """#
        #expect(output == expectation)
    }

    @Test("", arguments: ["http://localhost:3000", "http://localhost:3000/"])
    func imageEmptySource(baseUrl: String) {

        let input = #"""
            ![Lorem]()
            """#

        let output = renderHTML(baseUrl: baseUrl, markdown: input)

        let expectation = #"""
            <p></p>
            """#
        #expect(output == expectation)
    }

    @Test("", arguments: ["http://localhost:3000", "http://localhost:3000/"])
    func imageWithTitle(baseUrl: String) {

        let input = #"""
            ![Lorem](lorem.jpg "Image title")
            """#

        let output = renderHTML(baseUrl: baseUrl, markdown: input)

        let expectation = #"""
            <p><img src="lorem.jpg" alt="Lorem" title="Image title"></p>
            """#

        #expect(output == expectation)
    }

    @Test
    func imageWithEmptyBaseUrl() {

        let input = #"""
            ![Lorem](/lorem.jpg "Image title")
            """#

        let output = renderHTML(baseUrl: "", markdown: input)

        let expectation = #"""
            <p><img src="/lorem.jpg" alt="Lorem" title="Image title"></p>
            """#

        #expect(output == expectation)
    }

    @Test("", arguments: ["http://localhost:3000", "http://localhost:3000/"])
    func imageWithBaseUrlMarkdownValue(baseUrl: String) {

        let input = #"""
            ![Lorem]({{baseUrl}}/lorem.jpg)
            """#

        let output = renderHTML(baseUrl: baseUrl, markdown: input)

        let expectation = #"""
            <p><img src="http://localhost:3000/lorem.jpg" alt="Lorem"></p>
            """#

        #expect(output == expectation)
    }

    @Test("", arguments: ["http://localhost:3000", "http://localhost:3000/"])
    func imageWithBaseUrlMarkdownValueNoTraling(baseUrl: String) {

        let input = #"""
            ![Lorem]({{baseUrl}}lorem.jpg)
            """#

        let output = renderHTML(baseUrl: baseUrl, markdown: input)

        let expectation = #"""
            <p><img src="http://localhost:3000/lorem.jpg" alt="Lorem"></p>
            """#

        #expect(output == expectation)
    }

    @Test("", arguments: ["http://localhost:3000", "http://localhost:3000/"])
    func codeBlock(baseUrl: String) {

        let input = #"""
            ```js
            Lorem
            ipsum
            dolor
            sit
            amet
            ```
            """#

        let output = renderHTML(baseUrl: baseUrl, markdown: input)

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

    @Test("", arguments: ["http://localhost:3000", "http://localhost:3000/"])
    func codeBlockWithHighlight(baseUrl: String) {

        let input = #"""
            ```css
            Lorem
            /*!*/
                ipsum
            /*.*/
            dolor
            sit
            amet
            ```
            """#

        let output = renderHTML(baseUrl: baseUrl, markdown: input)

        let expectation = #"""
            <pre><code class="language-css">Lorem
            <span class="highlight">
                ipsum
            </span>
            dolor
            sit
            amet
            </code></pre>
            """#

        #expect(output == expectation)
    }

    @Test("", arguments: ["http://localhost:3000", "http://localhost:3000/"])
    func codeBlockWithHighlightSwift(baseUrl: String) {

        let input = #"""
            ```swift
            /*!*/func main() -> String/*.*/ {
                print("Hello world")
                return /*!*/"foo"/*.*/
            }
            ```
            """#

        let output = renderHTML(baseUrl: baseUrl, markdown: input)

        let expectation = #"""
            <pre><code class="language-swift"><span class="highlight">func main() -&gt; String</span> {
                print("Hello world")
                return <span class="highlight">"foo"</span>
            }
            </code></pre>
            """#

        #expect(output == expectation)
    }

    @Test("", arguments: ["http://localhost:3000", "http://localhost:3000/"])
    func table(baseUrl: String) {

        let input = #"""
            | Item              | In Stock | Price |
            | :---------------- | :------: | ----: |
            | Python Hat        |   True   | 23.99 |
            | SQL Hat           |   True   | 23.99 |
            | Codecademy Tee    |  False   | 19.99 |
            | Codecademy Hoodie |  False   | 42.99 |
            """#

        let output = renderHTML(baseUrl: baseUrl, markdown: input)

        let expectation = #"""
            <table><thead><td>Item</td><td>In Stock</td><td>Price</td></thead><tbody><tr><td>Python Hat</td><td>True</td><td>23.99</td></tr><tr><td>SQL Hat</td><td>True</td><td>23.99</td></tr><tr><td>Codecademy Tee</td><td>False</td><td>19.99</td></tr><tr><td>Codecademy Hoodie</td><td>False</td><td>42.99</td></tr></tbody></table>
            """#

        #expect(output == expectation)
    }
}
