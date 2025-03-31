import Foundation
import Testing
import ToucanModels

@testable import ToucanSource

@Suite
struct AnyValueDecodingTestSuite {

    @Test
    func decodingInt() throws {
        let json = "123"
        let data = json.dataValue()
        let decoded = try ToucanJSONDecoder()
            .decode(AnyCodable.self, from: data)

        #expect(decoded.value as? Int == 123)
    }

    @Test
    func decodingDouble() throws {
        let json = "123.45"
        let data = json.dataValue()
        let decoded = try ToucanJSONDecoder()
            .decode(AnyCodable.self, from: data)

        #expect(decoded.value as? Double == 123.45)
    }

    @Test
    func decodingBool() throws {
        let json = "true"
        let data = json.dataValue()
        let decoded = try ToucanJSONDecoder()
            .decode(AnyCodable.self, from: data)

        #expect(decoded.value as? Bool == true)
    }

    @Test
    func decodingString() throws {
        let json = #""Hello""#
        let data = json.dataValue()
        let decoded = try ToucanJSONDecoder()
            .decode(AnyCodable.self, from: data)

        #expect(decoded.value as? String == "Hello")
    }

    @Test
    func decodingArray() throws {
        let json = "[1, 2, 3]"
        let data = json.dataValue()
        let decoded = try ToucanJSONDecoder()
            .decode(AnyCodable.self, from: data)

        #expect(decoded.value as? [Int] == [1, 2, 3])
    }

    @Test
    func decodingDictionary() throws {
        let json = #"{"key1": 1, "key2": "value"}"#
        let data = json.dataValue()
        let decoded = try ToucanJSONDecoder()
            .decode(AnyCodable.self, from: data)

        let dict = decoded.value as? [String: AnyCodable]
        #expect(dict?["key1"] == 1)
        #expect(dict?["key2"] == "value")
    }

    @Test
    func decodingNestedStructures() throws {
        let data = """
            baseUrl: "https://theswiftdev.com/"
            locale: "en-US"
            title: "The.Swift.Dev."
            description: "Articles about application development using the Swift programming language."
            navigation:
                - label: "Posts"
                  url: "/page/1/"
                - label: "Tags"
                  url: "/tags/"
                - label: "Authors"
                  url: "/authors/"
                - label: "My Book"
                  url: "/practical-server-side-swift/"
            """
            .dataValue()

        _ = try ToucanYAMLDecoder()
            .decode(
                [String: AnyCodable].self,
                from: data
            )
    }
}
