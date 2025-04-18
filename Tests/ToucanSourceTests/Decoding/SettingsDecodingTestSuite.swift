//
//  SettingsDecodingTestSuite.swift
//  Toucan
//
//  Created by Binary Birds on 2025. 03. 30..

import Foundation
import Testing
import ToucanSource
import ToucanModels

@Suite
struct SettingsDecodingTestSuite {

    @Test
    func full() throws {
        let data = """
            baseUrl: "lorem1"
            name: "lorem2"
            locale: "lorem3"
            timeZone: "lorem4"
            foo:
                bar: baz
            """
            .dataValue()

        let decoder = ToucanYAMLDecoder()

        let result = try decoder.decode(
            Settings.self,
            from: data
        )

        #expect(result.baseUrl == "lorem1")
        #expect(result.name == "lorem2")
        #expect(result.locale == "lorem3")
        #expect(result.timeZone == "lorem4")
        let foo = try #require(
            result.userDefined["foo"]?.value as? [String: AnyCodable]
        )
        #expect(foo["bar"] == "baz")
        #expect(result.userDefined["name"] == nil)
    }

    @Test
    func defaults() throws {
        let data = """
            baseUrl: https://toucansites.com/
            """
            .dataValue()

        let decoder = ToucanYAMLDecoder()

        let result = try decoder.decode(
            Settings.self,
            from: data
        )

        #expect(result.baseUrl == "https://toucansites.com")
        #expect(result.name == "localhost")
        #expect(result.locale == "en-US")
        #expect(result.timeZone == "UTC")
        #expect(result.userDefined.isEmpty)
    }
}
