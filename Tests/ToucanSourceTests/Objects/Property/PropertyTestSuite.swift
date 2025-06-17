//
//  PropertyTestSuite.swift
//  Toucan
//
//  Created by Binary Birds on 2025. 03. 30..

import Foundation
import Testing
import ToucanSerialization

@testable import ToucanSource

@Suite
struct PropertyTestSuite {
    // MARK: - order

    @Test
    func stringType() throws {
        let data = """
            default: hello
            required: false
            type: string
            """

        let decoder = ToucanYAMLDecoder()
        let result = try decoder.decode(Property.self, from: data)
        let encoder = ToucanYAMLEncoder()
        let yaml = try encoder.encode(result)

        #expect(result.type == .string)
        #expect(result.required == false)
        #expect(result.default?.value as? String == "hello")

        #expect(
            data.trimmingCharacters(in: .whitespacesAndNewlines)
                == yaml.trimmingCharacters(in: .whitespacesAndNewlines)
        )
    }

    @Test
    func assetType() throws {
        let data = """
            required: true
            type: asset
            """

        let decoder = ToucanYAMLDecoder()
        let result = try decoder.decode(Property.self, from: data)
        let encoder = ToucanYAMLEncoder()
        let yaml = try encoder.encode(result)

        #expect(result.type == .asset)
        #expect(result.required == true)

        #expect(
            data.trimmingCharacters(in: .whitespacesAndNewlines)
                == yaml.trimmingCharacters(in: .whitespacesAndNewlines)
        )
    }

    @Test
    func dateTypeWithFormat() throws {
        let data = """
            type: date
            config: 
                format: "ymd"
                locale: en-US
                timeZone: EST

            """

        let decoder = ToucanYAMLDecoder()
        let result = try decoder.decode(Property.self, from: data)

        #expect(
            result.type
                == .date(
                    config: .init(
                        localization: .init(
                            locale: "en-US",
                            timeZone: "EST"
                        ),
                        format: "ymd"
                    )
                )
        )
        #expect(result.required == true)
        #expect(result.default == nil)
    }

    @Test
    func dateTypeWithoutFormat() throws {
        let data = """
            type: date
            required: true
            """

        let decoder = ToucanYAMLDecoder()
        let result = try decoder.decode(Property.self, from: data)

        #expect(result.type == .date(config: nil))
        #expect(result.required == true)
        #expect(result.default == nil)
    }
}
