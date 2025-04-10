//
//  ModelInitTests.swift
//  Toucan
//
//  Created by gerp83 on 2025. 04. 09.
//

import Testing
@testable import ToucanModels

@Suite
struct ModelInitTests {

    @Test
    func testInitContentTransformer() throws {
        let contentTransformer = ContentTransformer(
            name: "test",
            arguments: [:]
        )
        #expect(contentTransformer.name == "test")
    }

    @Test
    func testInitTransformerPipeline() throws {
        let transformerPipeline = TransformerPipeline(
            run: [
                .init(
                    name: "test",
                    arguments: [:]
                )
            ],
            isMarkdownResult: false
        )
        #expect(transformerPipeline.isMarkdownResult == false)
        #expect(transformerPipeline.run[0].name == "test")
    }

}
