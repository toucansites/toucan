//
//  File.swift
//  ToucanV2
//
//  Created by Tibor Bodecs on 2025. 01. 21..
//

import Foundation
import Testing
@testable import ToucanModels

@Suite
struct DataTypeTestSuite {
        
    private let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [
            .sortedKeys,
        ]
        return encoder
    }()
    
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        
        return decoder
    }()
    
    // MARK: -
    
    @Test
    func testEncodingBool() throws {
        let dataType: DataType = .bool
        let encodedData = try encoder.encode(dataType)
        let jsonString = String(data: encodedData, encoding: .utf8)
        
        #expect(jsonString == #"{"type":"bool"}"#)
    }
    
    @Test
    func testDecodingBool() throws {
        let jsonData = #"{"type":"bool"}"#.data(using: .utf8)!
        let decodedDataType = try decoder.decode(DataType.self, from: jsonData)
        
        #expect(decodedDataType == .bool)
    }
    
    @Test
    func testEncodingInt() throws {
        let dataType: DataType = .int
        let encodedData = try encoder.encode(dataType)
        let jsonString = String(data: encodedData, encoding: .utf8)
        
        #expect(jsonString == #"{"type":"int"}"#)
    }
    
    @Test
    func testDecodingInt() throws {
        let jsonData = #"{"type":"int"}"#.data(using: .utf8)!
        let decodedDataType = try decoder.decode(DataType.self, from: jsonData)
        
        #expect(decodedDataType == .int)
    }
    
    @Test
    func testEncodingDate() throws {
        let dataType: DataType = .date(format: "y.m.d")
        let encodedData = try encoder.encode(dataType)
        let jsonString = String(data: encodedData, encoding: .utf8)
        
        #expect(jsonString == #"{"format":"y.m.d","type":"date"}"#)
    }
    
    @Test
    func testDecodingDate() throws {
        let jsonData = #"{"format":"y.m.d","type":"date"}"#.data(using: .utf8)!
        let decodedDataType = try decoder.decode(DataType.self, from: jsonData)
        
        #expect(decodedDataType == .date(format: "y.m.d"))
    }
    
    @Test
    func testEncodingString() throws {
        let dataType: DataType = .string
        let encodedData = try encoder.encode(dataType)
        let jsonString = String(data: encodedData, encoding: .utf8)
        
        #expect(jsonString == #"{"type":"string"}"#)
    }
    
    @Test
    func testDecodingString() throws {
        let jsonData = #"{"type":"string"}"#.data(using: .utf8)!
        let decodedDataType = try decoder.decode(DataType.self, from: jsonData)
        
        #expect(decodedDataType == .string)
    }
}
