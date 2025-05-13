//
//  PropertyTypeDecodingTestSuite.swift
//  Toucan
//
//  Created by Tibor Bodecs on 2025. 01. 31..
//

import Foundation
import Testing
import ToucanModels
import ToucanSerialization

@Suite
struct PropertyTypeDecodingTestSuite {

    @Test
    func decodingBool() throws {
        let jsonData = #"{"type":"bool"}"#.dataValue()
        let decodedDataType = try ToucanJSONDecoder()
            .decode(
                PropertyType.self,
                from: jsonData
            )

        #expect(decodedDataType == .bool)
    }

    @Test
    func decodingInt() throws {
        let jsonData = #"{"type":"int"}"#.dataValue()
        let decodedDataType = try ToucanJSONDecoder()
            .decode(
                PropertyType.self,
                from: jsonData
            )

        #expect(decodedDataType == .int)
    }

    @Test
    func decodingDouble() throws {
        let jsonData = #"{"type":"double"}"#.dataValue()
        let decodedDataType = try ToucanJSONDecoder()
            .decode(
                PropertyType.self,
                from: jsonData
            )

        #expect(decodedDataType == .double)
    }

    @Test
    func decodingDate() throws {
        let jsonData = #"{"dateFormat":{"format":"y.m.d"},"type":"date"}"#
            .dataValue()
        let decodedDataType = try ToucanJSONDecoder()
            .decode(
                PropertyType.self,
                from: jsonData
            )

        #expect(decodedDataType == .date(format: .init(format: "y.m.d")))
    }

    @Test
    func decodingString() throws {
        let jsonData = #"{"type":"string"}"#.dataValue()
        let decodedDataType = try ToucanJSONDecoder()
            .decode(
                PropertyType.self,
                from: jsonData
            )

        #expect(decodedDataType == .string)
    }

    @Test
    func decodingArrayOfBool() throws {
        let jsonData = #"{"type":"array", "of": {"type": "bool"}}"#.dataValue()
        let decodedDataType = try ToucanJSONDecoder()
            .decode(
                PropertyType.self,
                from: jsonData
            )
        #expect(decodedDataType == .array(of: .bool))
    }

    @Test
    func decodingArrayOfInt() throws {
        let jsonData = #"{"type":"array", "of": {"type": "int"}}"#.dataValue()
        let decodedDataType = try ToucanJSONDecoder()
            .decode(
                PropertyType.self,
                from: jsonData
            )
        #expect(decodedDataType == .array(of: .int))
    }

    @Test
    func decodingArrayOfDouble() throws {
        let jsonData = #"{"type":"array", "of": {"type": "double"}}"#
            .dataValue()
        let decodedDataType = try ToucanJSONDecoder()
            .decode(
                PropertyType.self,
                from: jsonData
            )
        #expect(decodedDataType == .array(of: .double))
    }

    @Test
    func decodingArrayOfString() throws {
        let jsonData = #"{"type":"array", "of": {"type": "string"}}"#
            .dataValue()
        let decodedDataType = try ToucanJSONDecoder()
            .decode(
                PropertyType.self,
                from: jsonData
            )
        #expect(decodedDataType == .array(of: .string))
    }

    @Test
    func decodingArrayOfDate() throws {
        let jsonData =
            #"{"type":"array", "of": {"dateFormat":{"format":"y.m.d"}, "type": "date"}}"#
            .dataValue()
        let decodedDataType = try ToucanJSONDecoder()
            .decode(
                PropertyType.self,
                from: jsonData
            )
        #expect(
            decodedDataType == .array(of: .date(format: .init(format: "y.m.d")))
        )
    }

}
