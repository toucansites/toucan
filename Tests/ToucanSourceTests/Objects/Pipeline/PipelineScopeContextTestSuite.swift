//
//  PipelineScopeContextTestSuite.swift
//  Toucan
//
//  Created by Binary Birds on 2025. 03. 12..

import Foundation
import Testing
import ToucanSerialization

@testable import ToucanSource

@Suite
struct PipelineScopeContextTestSuite {
    @Test
    func initialization() throws {
        let result = Pipeline.Scope.Context(stringValue: "foo")

        #expect(!result.contains(.properties))
        #expect(!result.contains(.contents))
        #expect(!result.contains(.relations))
        #expect(!result.contains(.queries))
        #expect(!result.contains(.detail))
    }

    @Test
    func decodingMultipleValues() throws {
        let json =
            #"["\#(Pipeline.Scope.Context.Keys.contents.rawValue)", "\#(Pipeline.Scope.Context.Keys.queries.rawValue)"]"#
        let data = json.data(using: .utf8)!
        let result = try ToucanJSONDecoder()
            .decode(Pipeline.Scope.Context.self, from: data)

        #expect(!result.contains(.properties))
        #expect(result.contains(.contents))
        #expect(!result.contains(.relations))
        #expect(result.contains(.queries))
        #expect(!result.contains(.detail))
    }

    @Test
    func decodingSingleValue() throws {
        let json = #""\#(Pipeline.Scope.Context.Keys.properties.rawValue)""#
        let data = json.data(using: .utf8)!
        let result = try ToucanJSONDecoder()
            .decode(Pipeline.Scope.Context.self, from: data)

        #expect(result.contains(.properties))
        #expect(!result.contains(.contents))
        #expect(!result.contains(.relations))
        #expect(!result.contains(.queries))
        #expect(!result.contains(.detail))
    }

    @Test
    func decodingSingleAllValue() throws {
        let json = #""\#(Pipeline.Scope.Context.Keys.detail.rawValue)""#
        let data = json.data(using: .utf8)!
        let result = try ToucanJSONDecoder()
            .decode(Pipeline.Scope.Context.self, from: data)

        #expect(result.contains(.properties))
        #expect(result.contains(.contents))
        #expect(result.contains(.relations))
        #expect(result.contains(.queries))
        #expect(result.contains(.detail))
    }
}
