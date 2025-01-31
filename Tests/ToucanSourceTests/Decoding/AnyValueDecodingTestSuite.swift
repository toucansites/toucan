import Foundation
import Testing
@testable import ToucanSource

@Suite
struct AnyValueDecodingTestSuite {

    @Test
    func decodingInt() throws {
        let json = "123"
        let data = json.data(using: .utf8)!
        let decoded = try JSONDecoder().decode(AnyValue.self, from: data)

        #expect(decoded.value as? Int == 123)
    }

    @Test
    func decodingDouble() throws {
        let json = "123.45"
        let data = json.data(using: .utf8)!
        let decoded = try JSONDecoder().decode(AnyValue.self, from: data)

        #expect(decoded.value as? Double == 123.45)
    }

    @Test
    func decodingBool() throws {
        let json = "true"
        let data = json.data(using: .utf8)!
        let decoded = try JSONDecoder().decode(AnyValue.self, from: data)

        #expect(decoded.value as? Bool == true)
    }

    @Test
    func decodingString() throws {
        let json = #""Hello""#
        let data = json.data(using: .utf8)!
        let decoded = try JSONDecoder().decode(AnyValue.self, from: data)

        #expect(decoded.value as? String == "Hello")
    }

    @Test
    func decodingArray() throws {
        let json = "[1, 2, 3]"
        let data = json.data(using: .utf8)!
        let decoded = try JSONDecoder().decode(AnyValue.self, from: data)

        #expect(decoded.value as? [Int] == [1, 2, 3])
    }

    @Test
    func decodingDictionary() throws {
        let json = #"{"key1": 1, "key2": "value"}"#
        let data = json.data(using: .utf8)!
        let decoded = try JSONDecoder().decode(AnyValue.self, from: data)

        let dict = decoded.value as? [String: Any]
        #expect(dict?["key1"] as? Int == 1)
        #expect(dict?["key2"] as? String == "value")
    }

    @Test
    func decodingNestedStructures() throws {
        //        let json = "{\"array\": [1, \"two\", 3.5], \"nested\": {\"key\": false}}"
        //        let data = json.data(using: .utf8)!
        //        let decoded = try JSONDecoder().decode(AnyDecodable.self, from: data)
        //
        //        let dict = decoded.value as? [String: Any]
        //        #expect(dict?["array"] as? [Any] == [1, "two", 3.5])
        //        XCTAssertEqual((dict?["nested"] as? [String: Any])?["key"] as? Bool, false)
    }
}
