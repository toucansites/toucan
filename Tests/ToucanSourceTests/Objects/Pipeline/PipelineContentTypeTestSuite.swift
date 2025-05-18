//
//  PipelineContentTypeTestSuite.swift
//  Toucan
//
//  Created by Binary Birds on 2025. 03. 12..

import Foundation
import Testing
import ToucanSerialization

@testable import ToucanSource

@Suite
struct PipelineContentTypeTestSuite {

    @Test
    func empty() throws {
        let data = """
            foo: bar
            """
            .data(using: .utf8)!

        let decoder = ToucanYAMLDecoder()

        let result = try decoder.decode(
            Pipeline.ContentTypes.self,
            from: data
        )

        #expect(result.include.isEmpty)
        #expect(result.lastUpdate.isEmpty)
    }

    @Test
    func standard() throws {
        let data = """
            include:
                - post
            exclude:
                - rss
            lastUpdate:
                - page
            """
            .data(using: .utf8)!

        let decoder = ToucanYAMLDecoder()

        let result = try decoder.decode(
            Pipeline.ContentTypes.self,
            from: data
        )

        #expect(result.include == ["post"])
        #expect(result.exclude == ["rss"])
        #expect(result.lastUpdate == ["page"])
    }

}
