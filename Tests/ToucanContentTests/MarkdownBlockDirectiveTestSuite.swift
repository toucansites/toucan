import Testing
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

}
