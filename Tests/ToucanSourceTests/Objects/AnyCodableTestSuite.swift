//
//  AnyCodableTestSuite.swift
//  Toucan
//
//  Created by Binary Birds on 2025. 03. 30..

import Foundation
import Testing
import ToucanSerialization

@testable import ToucanSource

@Suite
struct AnyCodableTestSuite {

    struct SomeCodable: Codable {
        enum CodingKeys: String, CodingKey {
            case string
            case int
            case bool
            case hasUnderscore = "has_underscore"
        }

        var string: String
        var int: Int
        var bool: Bool
        var hasUnderscore: String
    }

    @Test
    func decodingInt() throws {
        let object = "123"

        let decoder = ToucanYAMLDecoder()
        let result = try decoder.decode(AnyCodable.self, from: object)

        #expect(result.value as? Int == 123)
    }

    @Test
    func decodingDouble() throws {
        let object = "123.45"

        let decoder = ToucanYAMLDecoder()
        let result = try decoder.decode(AnyCodable.self, from: object)

        #expect(result.value as? Double == 123.45)
    }

    @Test
    func decodingBool() throws {
        let object = "true"

        let decoder = ToucanYAMLDecoder()
        let result = try decoder.decode(AnyCodable.self, from: object)

        #expect(result.value as? Bool == true)
    }

    @Test
    func decodingString() throws {
        let object = "Hello"

        let decoder = ToucanYAMLDecoder()
        let result = try decoder.decode(AnyCodable.self, from: object)

        #expect(result.value as? String == "Hello")
    }

    @Test
    func decodingArray() throws {
        let object = "[1, 2, 3]"

        let decoder = ToucanYAMLDecoder()
        let result = try decoder.decode(AnyCodable.self, from: object)

        #expect(result.value as? [Int] == [1, 2, 3])
    }

    @Test
    func decodingDictionary() throws {
        let object = """
            key1: 1 
            key2: value
            """

        let decoder = ToucanYAMLDecoder()
        let result = try decoder.decode(AnyCodable.self, from: object)

        guard let dict = result.value as? [String: AnyCodable] else {
            Issue.record("Result is not a dictionary.")
            return
        }
        #expect(dict["key1"] == 1)
        #expect(dict["key2"] == "value")
    }

    @Test
    func decodingNestedStructures() throws {
        let object = """
            name: "Toucan"
            description: "Static Site Generator"
            navigation:
                - label: "Home"
                  url: "/"
            """

        let decoder = ToucanYAMLDecoder()
        let result = try decoder.decode(AnyCodable.self, from: object)

        guard let dict = result.value as? [String: AnyCodable] else {
            Issue.record("Result is not a dictionary.")
            return
        }
        #expect(dict["name"] == "Toucan")
    }

    @Test
    func jSONDecoding() throws {
        let json = """
            {
                "boolean": true,
                "integer": 42,
                "double": 3.141592653589793,
                "string": "string",
                "array": [1, 2, 3],
                "dict": {
                    "a": "alpha",
                    "b": "bravo",
                    "c": "charlie"
                },
                "null": null
            }
            """
            .data(using: .utf8)!

        let decoder = JSONDecoder()
        let dictionary = try decoder.decode(
            [String: AnyCodable].self,
            from: json
        )

        #expect(dictionary["boolean"]?.value as! Bool == true)
        #expect(dictionary["integer"]?.value as! Int == 42)
        #expect(dictionary["double"]?.value as! Double == 3.141592653589793)
        #expect(dictionary["string"]?.value as! String == "string")
        #expect(dictionary["array"]?.value as! [Int] == [1, 2, 3])
        #expect(
            dictionary["dict"]?.value as! [String: AnyCodable] == [
                "a": .init("alpha"),
                "b": .init("bravo"),
                "c": .init("charlie"),
            ]
        )
        #expect(dictionary["null"]?.value == nil)
    }

    @Test
    func jSONDecodingEquatable() throws {
        let json = """
            {
                "boolean": true,
                "integer": 42,
                "double": 3.141592653589793,
                "string": "string",
                "array": [1, 2, 3],
                "dict": {
                    "a": "alpha",
                    "b": "bravo",
                    "c": "charlie"
                },
                "null": null
            }
            """
            .data(using: .utf8)!

        let decoder = JSONDecoder()
        let dictionary1 = try decoder.decode(
            [String: AnyCodable].self,
            from: json
        )
        let dictionary2 = try decoder.decode(
            [String: AnyCodable].self,
            from: json
        )

        #expect(dictionary1["boolean"] == dictionary2["boolean"])
        #expect(dictionary1["integer"] == dictionary2["integer"])
        #expect(dictionary1["double"] == dictionary2["double"])
        #expect(dictionary1["string"] == dictionary2["string"])
        #expect(
            dictionary1["array"]?.value as? [Int] == dictionary2["array"]?.value
                as? [Int]
        )
        #expect(
            dictionary1["dict"]?.value as? [String: String] == dictionary2[
                "dict"
            ]?
                .value as? [String: String]
        )
        #expect(dictionary1["null"]?.value == nil)
        #expect(dictionary2["null"]?.value == nil)
    }

    @Test
    func jSONEncoding() throws {
        let someCodable = AnyCodable(
            SomeCodable(
                string: "String",
                int: 100,
                bool: true,
                hasUnderscore: "another string"
            )
        )

        let injectedValue = 1234
        let dictionary: [String: AnyCodable] = [
            "boolean": true,
            "integer": 42,
            "double": 3.141592653589793,
            "string": "string",
            "stringInterpolation": "string \(injectedValue)",
            "array": [1, 2, 3],
            "dict": [
                "a": "alpha",
                "b": "bravo",
                "c": "charlie",
            ],
            "someCodable": someCodable,
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
                "stringInterpolation": "string 1234",
                "array": [1, 2, 3],
                "dict": {
                    "a": "alpha",
                    "b": "bravo",
                    "c": "charlie"
                },
                "someCodable": {
                    "string": "String",
                    "int": 100,
                    "bool": true,
                    "has_underscore": "another string"
                },
                "null": null
            }
            """
            .data(using: .utf8)!

        let expectedJSONObject =
            try JSONSerialization.jsonObject(
                with: expected,
                options: []
            ) as! NSDictionary

        #expect(encodedJSONObject == expectedJSONObject)
    }

    @Test
    func allValues() throws {
        let boolValue = AnyCodable(true)
        let intValue = AnyCodable(100)
        let doubleValue = AnyCodable(100.1)
        let stringValue = AnyCodable("string")
        let nilValue = AnyCodable(nil)
        let arrayValue = AnyCodable([
            AnyCodable("string"), AnyCodable("string2"),
        ])
        let dictValue = AnyCodable(["key": AnyCodable("value")])

        // test values
        #expect(boolValue.boolValue() == true)
        #expect(intValue.intValue() == 100)
        #expect(doubleValue.doubleValue() == 100.1)
        #expect(stringValue.stringValue() == "string")
        #expect(nilValue.stringValue() == nil)
        #expect(
            arrayValue.arrayValue(as: AnyCodable.self) == [
                AnyCodable("string"), AnyCodable("string2"),
            ]
        )
        #expect(dictValue.dictValue() == ["key": AnyCodable("value")])
        #expect(arrayValue.arrayValue(as: Int.self) == [])
        #expect(arrayValue.dictValue() == [:])

        // test description/debugDescription
        #expect(boolValue.description == "true")
        #expect(boolValue.debugDescription == "AnyCodable(true)")
        #expect(intValue.description == "100")
        #expect(intValue.debugDescription == "AnyCodable(100)")
        #expect(doubleValue.description == "100.1")
        #expect(doubleValue.debugDescription == "AnyCodable(100.1)")
        #expect(stringValue.description == "string")
        #expect(stringValue.debugDescription == "AnyCodable(\"string\")")
        #expect(nilValue.description == "nil")
        #expect(nilValue.debugDescription == "AnyCodable(nil)")
        #expect(
            arrayValue.description
                == "[AnyCodable(\"string\"), AnyCodable(\"string2\")]"
        )
        #expect(
            arrayValue.debugDescription
                ==
                "AnyCodable([AnyCodable(\"string\"), AnyCodable(\"string2\")])"
        )
        #expect(dictValue.description == "[\"key\": AnyCodable(\"value\")]")
        #expect(
            dictValue.debugDescription
                == "AnyCodable([\"key\": AnyCodable(\"value\")])"
        )

        // hash
        _ = boolValue.hashValue
        _ = intValue.hashValue
        _ = doubleValue.hashValue
        _ = stringValue.hashValue
        _ = nilValue.hashValue
        _ = arrayValue.hashValue
        _ = dictValue.hashValue
    }

    @Test
    func allComparisons() throws {
        let boolValue = AnyCodable(true)
        let boolValue2 = AnyCodable(true)
        let intValue = AnyCodable(100)
        let intValue2 = AnyCodable(100)
        let doubleValue = AnyCodable(100.1)
        let doubleValue2 = AnyCodable(100.1)
        let stringValue = AnyCodable("string")
        let stringValue2 = AnyCodable("string")
        let nilValue = AnyCodable(nil)
        let nilValue2 = AnyCodable(nil)
        let arrayValue = AnyCodable([
            AnyCodable("string"), AnyCodable("string2"),
        ])
        let arrayValue2 = AnyCodable([
            AnyCodable("string"), AnyCodable("string2"),
        ])
        let dictValue = AnyCodable(["key": AnyCodable("value")])
        let dictValue2 = AnyCodable(["key": AnyCodable("value")])

        #expect(boolValue == boolValue2)
        #expect(intValue == intValue2)
        #expect(doubleValue == doubleValue2)
        #expect(stringValue == stringValue2)
        #expect(nilValue == nilValue2)
        #expect(arrayValue == arrayValue2)
        #expect(dictValue == dictValue2)
        #expect(dictValue != arrayValue)
    }
}
