import Testing
@testable import ToucanMarkdown

@Suite
struct MarkdownRendererTestSuite {

    @Test
    func simpleCustomBlockDirective() throws {

        let renderer = MarkdownRenderer(
            customBlockDirectives: [
                .init(
                    name: "FAQ",
                    parameters: nil,
                    requiresParentDirective: nil,
                    removesChildParagraph: nil,
                    tag: "div",
                    attributes: [
                        .init(name: "class", value: "faq")
                    ],
                    output: nil
                )
            ]
        )
        
        let input = #"""
            @FAQ {
                Lorem ipsum
            }
            """#

        
        let output = renderer.renderHTML(markdown: input)

        let expectation = #"""
            <div class="faq"><p>Lorem ipsum</p></div>
            """#

        #expect(output == expectation)
    }

}
