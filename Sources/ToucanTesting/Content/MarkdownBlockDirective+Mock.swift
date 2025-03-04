import Foundation
import ToucanModels
import ToucanContent

public extension MarkdownBlockDirective.Mocks {

    static func highlightedTexts(
        max: Int = 10
    ) -> [MarkdownBlockDirective] {
        (1...max)
            .map { i in
                .init(
                    name: "HighlightedText-\(i)",
                    parameters: nil,
                    requiresParentDirective: nil,
                    removesChildParagraph: nil,
                    tag: "div",
                    attributes: [
                        MarkdownBlockDirective.Attribute(
                            name: "class",
                            value: "highlighted-text"
                        )
                    ],
                    output: nil
                )
            }
    }
}
