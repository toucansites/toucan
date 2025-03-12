import Testing
@testable import ToucanContent

@Suite
struct ContentRendererTestSuite {

    @Test
    func basicRendering() throws {

        let renderer = ContentRenderer(
            configuration: .init(
                markdown: .init(
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
                ),
                outline: .init(
                    levels: [2, 3]
                ),
                readingTime: .init(
                    wordsPerMinute: 238
                )
            ),
            logger: .init(
                label: "test"
            )
        )

        let input = #"""
            @FAQ {
                ## test 
                Lorem ipsum
            }
            """#

        let contents = renderer.render(
            content: input,
            slug: "",
            assetsPath: "",
            baseUrl: ""
        )

        let html = #"""
            <div class="faq"><h2 id="test">test</h2><p>Lorem ipsum</p></div>
            """#

        #expect(contents.html == html)
        #expect(
            contents.outline == [
                .init(
                    level: 2,
                    text: "test",
                    fragment: "test"
                )
            ]
        )
        #expect(contents.readingTime == 1)
    }

}
