//
//  AnyEncodableTests.swift
//  Toucan
//
//  Created by Binary Birds on 2025. 03. 12..

import Foundation
import Testing
@testable import ToucanModels

@Suite
struct AnyEncodableTests {

    struct SomeEncodable: Encodable {
        var string: String
        var int: Int
        var bool: Bool
        var hasUnderscore: String

        enum CodingKeys: String, CodingKey {
            case string
            case int
            case bool
            case hasUnderscore = "has_underscore"
        }
    }

    @Test
    func testJSONEncoding() throws {

        let someEncodable = AnyCodable(
            SomeEncodable(
                string: "String",
                int: 100,
                bool: true,
                hasUnderscore: "another string"
            )
        )

        let dictionary: [String: AnyCodable] = [
            "boolean": true,
            "integer": 42,
            "double": 3.141592653589793,
            "string": "string",
            "array": [1, 2, 3],
            "nested": [
                "a": "alpha",
                "b": "bravo",
                "c": "charlie",
            ],
            "someCodable": someEncodable,
            "null": nil,
        ]

        let encoder = JSONEncoder()

        let json = try encoder.encode(dictionary)
        let encodedJSONObject =
            try JSONSerialization.jsonObject(with: json, options: [])
            as! NSDictionary

        let expected = """
            {
                "boolean": true,
                "integer": 42,
                "double": 3.141592653589793,
                "string": "string",
                "array": [1, 2, 3],
                "nested": {
                    "a": "alpha",
                    "b": "bravo",
                    "c": "charlie"
                },
                "someCodable": {
                    "string":"String",
                    "int":100,
                    "bool": true,
                    "has_underscore":"another string"
                },
                "null": null
            }
            """
            .dataValue()
        let expectedJSONObject =
            try JSONSerialization.jsonObject(with: expected, options: [])
            as! NSDictionary

        #expect(encodedJSONObject == expectedJSONObject)
    }

    @Test
    func testEncodeNSNumber() throws {
        let dictionary: [String: NSNumber] = [
            "boolean": true,
            "char": -127,
            "int": -32767,
            "short": -32767,
            "long": -2_147_483_647,
            "longlong": -9_223_372_036_854_775_807,
            "uchar": 255,
            "uint": 65535,
            "ushort": 65535,
            "ulong": 4_294_967_295,
            "ulonglong": 18_446_744_073_709_615,
            "double": 3.141592653589793,
        ]

        let encoder = JSONEncoder()

        let json = try encoder.encode(AnyCodable(dictionary))
        let encodedJSONObject =
            try JSONSerialization.jsonObject(with: json, options: [])
            as! NSDictionary

        let expected = """
            {
                "boolean": true,
                "char": -127,
                "int": -32767,
                "short": -32767,
                "long": -2147483647,
                "longlong": -9223372036854775807,
                "uchar": 255,
                "uint": 65535,
                "ushort": 65535,
                "ulong": 4294967295,
                "ulonglong": 18446744073709615,
                "double": 3.141592653589793,
            }
            """
            .dataValue()
        let expectedJSONObject =
            try JSONSerialization.jsonObject(with: expected, options: [])
            as! NSDictionary

        #expect(encodedJSONObject == expectedJSONObject)
        #expect(encodedJSONObject["boolean"] is Bool)

        #expect(encodedJSONObject["char"] is Int8)
        #expect(encodedJSONObject["int"] is Int16)
        #expect(encodedJSONObject["short"] is Int32)
        #expect(encodedJSONObject["long"] is Int32)
        #expect(encodedJSONObject["longlong"] is Int64)

        #expect(encodedJSONObject["uchar"] is UInt8)
        #expect(encodedJSONObject["uint"] is UInt16)
        #expect(encodedJSONObject["ushort"] is UInt32)
        #expect(encodedJSONObject["ulong"] is UInt32)
        #expect(encodedJSONObject["ulonglong"] is UInt64)

        #expect(encodedJSONObject["double"] is Double)
    }

    @Test
    func testStringInterpolationEncoding() throws {
        let dictionary: [String: AnyCodable] = [
            "boolean": "\(true)",
            "integer": "\(42)",
            "double": "\(3.141592653589793)",
            "string": "\("string")",
            "array": "\([1, 2, 3])",
        ]

        let encoder = JSONEncoder()

        let json = try encoder.encode(dictionary)
        let encodedJSONObject =
            try JSONSerialization.jsonObject(with: json, options: [])
            as! NSDictionary

        let expected = """
            {
                "boolean": "true",
                "integer": "42",
                "double": "3.141592653589793",
                "string": "string",
                "array": "[1, 2, 3]",
            }
            """
            .dataValue()
        let expectedJSONObject =
            try JSONSerialization.jsonObject(with: expected, options: [])
            as! NSDictionary

        #expect(encodedJSONObject == expectedJSONObject)
    }
}
