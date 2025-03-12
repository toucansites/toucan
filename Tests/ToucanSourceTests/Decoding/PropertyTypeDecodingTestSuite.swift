//
//  File.swift
//  toucan
//
//  Created by Tibor Bodecs on 2025. 01. 31..
//

import Foundation
import Testing
import ToucanModels
@testable import ToucanSource

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
        let jsonData = #"{"format":"y.m.d","type":"date"}"#.dataValue()
        let decodedDataType = try ToucanJSONDecoder()
            .decode(
                PropertyType.self,
                from: jsonData
            )

        #expect(decodedDataType == .date(format: "y.m.d"))
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

    //    private var encoder: JSONEncoder {
    //        let encoder = JSONEncoder()
    //        encoder.outputFormatting = [
    //            .sortedKeys
    //        ]
    //        return encoder
    //    }
    //
    //    @Test
    //    func encodingBool() throws {
    //        let dataType: PropertyType = .bool
    //        let encodedData = try encoder.encode(dataType)
    //        let jsonString = String(data: encodedData, encoding: .utf8)
    //
    //        #expect(jsonString == #"{"type":"bool"}"#)
    //    }
    //
    //    @Test
    //    func encodingInt() throws {
    //        let dataType: PropertyType = .int
    //        let encodedData = try encoder.encode(dataType)
    //        let jsonString = String(data: encodedData, encoding: .utf8)
    //
    //        #expect(jsonString == #"{"type":"int"}"#)
    //    }
    //
    //    @Test
    //    func encodingDouble() throws {
    //        let dataType: PropertyType = .double
    //        let encodedData = try encoder.encode(dataType)
    //        let jsonString = String(data: encodedData, encoding: .utf8)
    //
    //        #expect(jsonString == #"{"type":"double"}"#)
    //    }
    //
    //    @Test
    //    func encodingDate() throws {
    //        let dataType: PropertyType = .date(format: "y.m.d")
    //        let encodedData = try encoder.encode(dataType)
    //        let jsonString = String(data: encodedData, encoding: .utf8)
    //
    //        #expect(jsonString == #"{"format":"y.m.d","type":"date"}"#)
    //    }
    //
    //    @Test
    //    func encodingString() throws {
    //        let dataType: PropertyType = .string
    //        let encodedData = try encoder.encode(dataType)
    //        let jsonString = String(data: encodedData, encoding: .utf8)
    //
    //        #expect(jsonString == #"{"type":"string"}"#)
    //    }
}
