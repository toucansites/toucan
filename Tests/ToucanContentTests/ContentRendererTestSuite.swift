//
//  ContentRendererTestSuite.swift
//  Toucan
//
//  Created by Binary Birds on 2025. 04. 15..

import Foundation
import Testing
import Logging

@testable import ToucanContent

@Suite
struct ContentRendererTestSuite {

    @Test
    func basicRendering() throws {
        let logger = Logger(label: "ContentRendererTestSuite")
        let renderer = ContentRenderer(
            configuration: .init(
                markdown: .init(
                    customBlockDirectives: [
                        MarkdownBlockDirective.Mocks.faq()
                    ]
                ),
                outline: .init(
                    levels: [2, 3]
                ),
                readingTime: .init(
                    wordsPerMinute: 238
                ),
                transformerPipeline: nil,
                paragraphStyles: [:]
            ),
            fileManager: FileManager.default,
            logger: logger
        )

        let input = #"""
            @FAQ {
                ## test 
                Lorem ipsum
            }
            """#

        let contents = renderer.render(
            content: input,
            slug: .init(value: ""),
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
