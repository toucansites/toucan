import Foundation
import Testing
@testable import ToucanModels

@Suite
struct AnyCodableTests {

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
    func testJSONDecoding() throws {
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
            dictionary["dict"]?.value as! [String: String] == [
                "a": "alpha", "b": "bravo", "c": "charlie",
            ]
        )
        #expect(dictionary["null"]?.value == nil)
    }

    @Test
    func testJSONDecodingEquatable() throws {
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
    func testJSONEncoding() throws {

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
        print(dictionary)

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
}
