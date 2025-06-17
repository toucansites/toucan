//
//  SettingsTestSuite.swift
//  Toucan
//
//  Created by Binary Birds on 2025. 03. 30..

import Foundation
import Testing
import ToucanSerialization

@testable import ToucanSource

@Suite
struct SettingsTestSuite {
    @Test
    func defaults() throws {
        let object = Settings.defaults
        let encoder = ToucanYAMLEncoder()
        let decoder = ToucanYAMLDecoder()

        let value1: String = try encoder.encode(object)
        let result1 = try decoder.decode(Settings.self, from: value1)

        let value2: Data = try encoder.encode(object)
        let result2 = try decoder.decode(Settings.self, from: value2)

        #expect(object == result1)
        #expect(object == result2)
    }

    @Test
    func empty() throws {
        let value = ""
        let decoder = ToucanYAMLDecoder()
        let result = try decoder.decode(Settings.self, from: value)
        let expectation = Settings.defaults

        #expect(result == expectation)
    }

    @Test
    func custom() throws {
        let value = """
        foo: bar
        """ + "\n"

        let encoder = ToucanYAMLEncoder()
        let decoder = ToucanYAMLDecoder()
        let result = try decoder.decode(Settings.self, from: value)

        var expectation = Settings.defaults
        expectation.values["foo"] = "bar"

        let encodedValue: String = try encoder.encode(expectation)

        #expect(result == expectation)
        #expect(value == encodedValue)
    }
}
