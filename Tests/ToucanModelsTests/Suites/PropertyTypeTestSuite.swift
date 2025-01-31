import Foundation
import Testing
@testable import ToucanModels

@Suite
struct PropertyTypeTestSuite {

    private let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [
            .sortedKeys
        ]
        return encoder
    }()

    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()

        return decoder
    }()

    // MARK: -

    @Test
    func equality() throws {
        #expect(PropertyType.bool == .bool)
        #expect(PropertyType.bool != .int)
        #expect(PropertyType.int == .int)
        #expect(PropertyType.int != .double)
        #expect(PropertyType.double == .double)
        #expect(PropertyType.double != .string)
        #expect(PropertyType.string == .string)
        #expect(PropertyType.string != .date(format: nil))
        #expect(PropertyType.date(format: nil) == .date(format: nil))
        #expect(PropertyType.date(format: nil) != .date(format: "y.m.d"))
    }

    @Test
    func encodingBool() throws {
        let dataType: PropertyType = .bool
        let encodedData = try encoder.encode(dataType)
        let jsonString = String(data: encodedData, encoding: .utf8)

        #expect(jsonString == #"{"type":"bool"}"#)
    }

    @Test
    func decodingBool() throws {
        let jsonData = #"{"type":"bool"}"#.data(using: .utf8)!
        let decodedDataType = try decoder.decode(
            PropertyType.self,
            from: jsonData
        )

        #expect(decodedDataType == .bool)
    }

    @Test
    func encodingInt() throws {
        let dataType: PropertyType = .int
        let encodedData = try encoder.encode(dataType)
        let jsonString = String(data: encodedData, encoding: .utf8)

        #expect(jsonString == #"{"type":"int"}"#)
    }

    @Test
    func decodingInt() throws {
        let jsonData = #"{"type":"int"}"#.data(using: .utf8)!
        let decodedDataType = try decoder.decode(
            PropertyType.self,
            from: jsonData
        )

        #expect(decodedDataType == .int)
    }

    @Test
    func encodingDouble() throws {
        let dataType: PropertyType = .double
        let encodedData = try encoder.encode(dataType)
        let jsonString = String(data: encodedData, encoding: .utf8)

        #expect(jsonString == #"{"type":"double"}"#)
    }

    @Test
    func decodingDouble() throws {
        let jsonData = #"{"type":"double"}"#.data(using: .utf8)!
        let decodedDataType = try decoder.decode(
            PropertyType.self,
            from: jsonData
        )

        #expect(decodedDataType == .double)
    }

    @Test
    func encodingDate() throws {
        let dataType: PropertyType = .date(format: "y.m.d")
        let encodedData = try encoder.encode(dataType)
        let jsonString = String(data: encodedData, encoding: .utf8)

        #expect(jsonString == #"{"format":"y.m.d","type":"date"}"#)
    }

    @Test
    func decodingDate() throws {
        let jsonData = #"{"format":"y.m.d","type":"date"}"#.data(using: .utf8)!
        let decodedDataType = try decoder.decode(
            PropertyType.self,
            from: jsonData
        )

        #expect(decodedDataType == .date(format: "y.m.d"))
    }

    @Test
    func encodingString() throws {
        let dataType: PropertyType = .string
        let encodedData = try encoder.encode(dataType)
        let jsonString = String(data: encodedData, encoding: .utf8)

        #expect(jsonString == #"{"type":"string"}"#)
    }

    @Test
    func decodingString() throws {
        let jsonData = #"{"type":"string"}"#.data(using: .utf8)!
        let decodedDataType = try decoder.decode(
            PropertyType.self,
            from: jsonData
        )

        #expect(decodedDataType == .string)
    }
}
