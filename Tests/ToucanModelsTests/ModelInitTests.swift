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
        let contentTransformer = ContentTransformer(name: "test")
        #expect(contentTransformer.name == "test")
    }

    @Test
    func testInitTransformerPipeline() throws {
        let transformerPipeline = TransformerPipeline(
            run: [
                .init(name: "test")
            ],
            isMarkdownResult: false
        )
        #expect(transformerPipeline.isMarkdownResult == false)
        #expect(transformerPipeline.run[0].name == "test")
    }

    @Test
    func testInitReservedFrontMatter() throws {
        let reservedFrontMatter = ReservedFrontMatter(
            type: "test"
        )
        #expect(reservedFrontMatter.type == "test")

        let empty = ReservedFrontMatter.empty()
        #expect(empty.type == nil)
    }

}
