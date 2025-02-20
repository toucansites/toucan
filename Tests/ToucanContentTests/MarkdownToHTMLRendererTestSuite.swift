import Testing
@testable import ToucanContent

@Suite
struct MarkdownRendererTestSuite {

    @Test
    func simpleCustomBlockDirective() throws {

        let renderer = MarkdownToHTMLRenderer(
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

    @Test
    func customBlockDirectiveParameters() throws {

        let renderer = MarkdownToHTMLRenderer(
            customBlockDirectives: [
                .init(
                    name: "Grid",
                    parameters: [
                        .init(
                            label: "columns",
                            required: true,
                            default: nil
                        )
                    ],
                    requiresParentDirective: nil,
                    removesChildParagraph: nil,
                    tag: "div",
                    attributes: [
                        .init(name: "columns", value: "grid-{{columns}}")
                    ],
                    output: nil  //#"<div class="faq">{{contents}}</div>"#
                )
            ]
        )

        let input = #"""
            @Grid(columns: 3) {
                Lorem ipsum
            }
            """#

        let output = renderer.renderHTML(markdown: input)

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
                            required: true,
                            default: nil
                        )
                    ],
                    requiresParentDirective: nil,
                    removesChildParagraph: nil,
                    tag: nil,
                    attributes: nil,
                    output:
                        #"<div columns="grid-{{columns}}">{{contents}}</div>"#
                )
            ]
        )

        let input = #"""
            @Grid(columns: 3) {
                Lorem ipsum
            }
            """#

        let output = renderer.renderHTML(markdown: input)

        let expectation = #"""
            <div columns="grid-3"><p>Lorem ipsum</p></div>
            """#

        #expect(output == expectation)
    }

}
