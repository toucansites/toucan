//
//  PropertyDecodingTestSuite.swift
//  Toucan
//
//  Created by Binary Birds on 2025. 03. 30..

import Foundation
import Testing
import ToucanModels
import ToucanSerialization

@Suite
struct PropertyDecodingTestSuite {

    // MARK: - order

    @Test
    func stringType() throws {
        let data = """
            type: string
            required: false
            default: hello
            """
            .dataValue()

        let decoder = ToucanYAMLDecoder()

        let result = try decoder.decode(
            Property.self,
            from: data
        )

        #expect(result.type == .string)
        #expect(result.required == false)
        #expect(result.default?.value as? String == "hello")
    }

    @Test
    func dateTypeWithFormat() throws {
        let data = """
            type: date
            dateFormat: 
                format: "ymd"
                locale: en-US
                timeZone: EST

            """
            .dataValue()

        let decoder = ToucanYAMLDecoder()

        let result = try decoder.decode(
            Property.self,
            from: data
        )

        #expect(
            result.type
                == .date(
                    format: .init(
                        locale: "en-US",
                        timeZone: "EST",
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
            .dataValue()

        let decoder = ToucanYAMLDecoder()

        let result = try decoder.decode(
            Property.self,
            from: data
        )

        #expect(result.type == .date(format: nil))
        #expect(result.required == true)
        #expect(result.default == nil)
    }
}
