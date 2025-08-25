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
    func invalidKey() throws {
        let data = """
            foo: bar
            """
            .data(using: .utf8)!

        let decoder = ToucanYAMLDecoder()

        do {
            let _ = try decoder.decode(Pipeline.ContentTypes.self, from: data)
        }
        catch {
            if let context = error.lookup({
                if case let DecodingError.dataCorrupted(ctx) = $0 {
                    return ctx
                }
                return nil
            }) {
                let expected =
                    "Unknown keys found: `foo`. Expected keys: `exclude`, `filterRules`, `include`, `lastUpdate`."
                #expect(context.debugDescription == expected)
            }
            else {
                throw error
            }
        }
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
