//
//  ContextDecodingTestSuite.swift
//  Toucan
//
//  Created by Binary Birds on 2025. 03. 12..

import Foundation
import Testing
import ToucanModels
import ToucanSerialization

@Suite
struct ContextDecodingTestSuite {

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
        let json = #"["contents", "queries"]"#
        let data = json.dataValue()
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
        let json = #""properties""#
        let data = json.dataValue()
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
        let json = #""detail""#
        let data = json.dataValue()
        let result = try ToucanJSONDecoder()
            .decode(Pipeline.Scope.Context.self, from: data)

        #expect(result.contains(.properties))
        #expect(result.contains(.contents))
        #expect(result.contains(.relations))
        #expect(result.contains(.queries))
        #expect(result.contains(.detail))
    }
}
