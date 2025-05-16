//
//  SettingsDecodingTestSuite.swift
//  Toucan
//
//  Created by Binary Birds on 2025. 03. 30..

import Foundation
import Testing
import ToucanModels
import ToucanSerialization

@Suite
struct SettingsDecodingTestSuite {

    @Test
    func full() throws {
        let data = """
            name: "lorem2"
            foo:
                bar: baz
            """
            .dataValue()

        let decoder = ToucanYAMLDecoder()

        let result = try decoder.decode(
            Settings.self,
            from: data
        )

        let foo = try #require(
            result.userDefined["foo"]?.value as? [String: AnyCodable]
        )
        #expect(foo["bar"] == "baz")
        #expect(result.userDefined["name"] == "lorem2")
    }

    @Test
    func defaults() throws {
        let data = """
            """
            .dataValue()

        let decoder = ToucanYAMLDecoder()

        let result = try decoder.decode(
            Settings.self,
            from: data
        )

        #expect(result.userDefined.isEmpty)
    }
}
