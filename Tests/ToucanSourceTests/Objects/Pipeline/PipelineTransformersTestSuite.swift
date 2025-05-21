//
//  PipelineTransformersTestSuite.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 05. 18..
//

import Foundation
import Testing
import ToucanSerialization

@testable import ToucanSource

@Suite
struct PipelineTransformersTestSuite {

    @Test
    func initWithName() throws {
        let contentTransformer = Pipeline.Transformers.Transformer(
            name: "test"
        )
        #expect(contentTransformer.name == "test")
    }

    @Test
    func initWithRun() throws {
        let transformerPipeline = Pipeline.Transformers(
            run: [
                .init(name: "test")
            ],
            isMarkdownResult: false
        )
        #expect(transformerPipeline.isMarkdownResult == false)
        #expect(transformerPipeline.run[0].name == "test")
    }
}
