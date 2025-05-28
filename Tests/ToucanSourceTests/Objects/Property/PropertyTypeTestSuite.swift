//
//  PropertyTypeTestSuite.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 01. 31..
//

import Foundation
import Testing
import ToucanSerialization

@testable import ToucanSource

@Suite
struct PropertyTypeTestSuite {

    @Test
    func equality() throws {
        let dateFormat = PropertyType.date(config: nil)
        #expect(PropertyType.bool == .bool)
        #expect(PropertyType.bool != .int)
        #expect(PropertyType.int == .int)
        #expect(PropertyType.int != .double)
        #expect(PropertyType.double == .double)
        #expect(PropertyType.double != .string)
        #expect(PropertyType.string == .string)
        #expect(PropertyType.string != dateFormat)
        #expect(dateFormat == .date(config: nil))
        #expect(
            dateFormat
                != .date(
                    config: .init(
                        localization: .defaults,
                        format: "y.m.d"
                    )
                )
        )
    }

    @Test
    func decodingBool() throws {
        let object = """
            type: bool
            """

        let decoder = ToucanYAMLDecoder()
        let result = try decoder.decode(PropertyType.self, from: object)

        #expect(result == .bool)
    }

    @Test
    func decodingInt() throws {
        let object = """
            type: int
            """

        let decoder = ToucanYAMLDecoder()
        let result = try decoder.decode(PropertyType.self, from: object)

        #expect(result == .int)
    }

    @Test
    func decodingDouble() throws {
        let object = """
            type: double
            """

        let decoder = ToucanYAMLDecoder()
        let result = try decoder.decode(PropertyType.self, from: object)

        #expect(result == .double)
    }

    @Test
    func decodingString() throws {
        let object = """
            type: string
            """

        let decoder = ToucanYAMLDecoder()
        let result = try decoder.decode(PropertyType.self, from: object)

        #expect(result == .string)
    }

    @Test
    func decodingDate() throws {
        let object = """
            type: date
            config:
                format: "y.m.d"
            """

        let decoder = ToucanYAMLDecoder()
        let result = try decoder.decode(PropertyType.self, from: object)

        #expect(
            result
                == .date(
                    config: .init(
                        localization: .defaults,
                        format: "y.m.d"
                    )
                )
        )
    }

    @Test
    func decodingArrayOfBool() throws {
        let object = """
            type: array
            of: 
                type: bool
            """

        let decoder = ToucanYAMLDecoder()
        let result = try decoder.decode(PropertyType.self, from: object)

        #expect(result == .array(of: .bool))
    }

    @Test
    func decodingArrayOfInt() throws {
        let object = """
            type: array
            of: 
                type: int
            """

        let decoder = ToucanYAMLDecoder()
        let result = try decoder.decode(PropertyType.self, from: object)

        #expect(result == .array(of: .int))
    }

    @Test
    func decodingArrayOfDouble() throws {
        let object = """
            type: array
            of: 
                type: double
            """

        let decoder = ToucanYAMLDecoder()
        let result = try decoder.decode(PropertyType.self, from: object)

        #expect(result == .array(of: .double))
    }

    @Test
    func decodingArrayOfString() throws {
        let object = """
            type: array
            of: 
                type: string
            """

        let decoder = ToucanYAMLDecoder()
        let result = try decoder.decode(PropertyType.self, from: object)

        #expect(result == .array(of: .string))
    }

    @Test
    func decodingArrayOfDate() throws {
        let object = """
            type: array
            of: 
                type: date
                config:
                    format: "y.m.d"
            """

        let decoder = ToucanYAMLDecoder()
        let result = try decoder.decode(PropertyType.self, from: object)

        #expect(
            result
                == .array(
                    of: .date(
                        config: .init(
                            localization: .defaults,
                            format: "y.m.d"
                        )
                    )
                )
        )
    }

}
