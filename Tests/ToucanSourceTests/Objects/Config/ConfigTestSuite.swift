//
//  ConfigTestSuite.swift
//  Toucan
//
//  Created by Binary Birds on 2025. 04. 17..

import Foundation
import Testing
import ToucanSerialization

@testable import ToucanSource

@Suite
struct ConfigTestSuite {
    @Test
    func defaults() throws {
        let object = Config.defaults
        let encoder = ToucanYAMLEncoder()
        let decoder = ToucanYAMLDecoder()

        let value1: String = try encoder.encode(object)
        let result1 = try decoder.decode(Config.self, from: value1)

        let value2: Data = try encoder.encode(object)
        let result2 = try decoder.decode(Config.self, from: value2)

        #expect(object == result1)
        #expect(object == result2)
    }

    @Test
    func empty() throws {
        let value = ""
        let decoder = ToucanYAMLDecoder()
        let result = try decoder.decode(Config.self, from: value)
        let expectation = Config.defaults

        #expect(result == expectation)
    }

    @Test
    func custom() throws {
        let value = """
            blocks:
              path: custom1
            contents:
              assets:
                path: custom2
              path: custom3
            dataTypes:
              date:
                formats:
                  test1:
                    format: his
                    locale: hu-HU
                    timeZone: CET
                input:
                  format: ymd
                output:
                  locale: en-GB
                  timeZone: PST
            pipelines:
              path: custom4
            renderer:
              outlineLevels:
              - 4
              paragraphStyles:
                test:
                - test1
              wordsPerMinute: 42
            site:
              assets:
                path: custom5
              settings:
                path: custom6
            templates:
              assets:
                path: custom7
              current:
                path: custom8
              location:
                path: custom9
              overrides:
                path: custom10
              views:
                path: custom11
            types:
              path: custom12
            """ + "\n"

        let encoder = ToucanYAMLEncoder()
        let decoder = ToucanYAMLDecoder()
        let result = try decoder.decode(Config.self, from: value)

        var expectation = Config.defaults
        expectation.blocks.path = "custom1"
        expectation.contents.assets.path = "custom2"
        expectation.contents.path = "custom3"
        expectation.dataTypes.date.input = .init(
            localization: .defaults,
            format: "ymd"
        )
        expectation.dataTypes.date.output = .init(
            locale: "en-GB",
            timeZone: "PST"
        )
        expectation.dataTypes.date.formats["test1"] = .init(
            localization: .init(
                locale: "hu-HU",
                timeZone: "CET"
            ),
            format: "his"
        )
        expectation.pipelines.path = "custom4"
        expectation.renderer.outlineLevels = [4]
        expectation.renderer.paragraphStyles.styles = [
            "test": [
                "test1"
            ]
        ]
        expectation.renderer.wordsPerMinute = 42
        expectation.site.assets.path = "custom5"
        expectation.site.settings.path = "custom6"
        expectation.templates.assets.path = "custom7"
        expectation.templates.current.path = "custom8"
        expectation.templates.location.path = "custom9"
        expectation.templates.overrides.path = "custom10"
        expectation.templates.views.path = "custom11"
        expectation.types.path = "custom12"

        #expect(result.blocks == expectation.blocks)
        #expect(result.contents == expectation.contents)
        #expect(result.dataTypes == expectation.dataTypes)
        #expect(result.pipelines == expectation.pipelines)
        #expect(result.renderer == expectation.renderer)
        #expect(result.site == expectation.site)
        #expect(result.templates == expectation.templates)
        #expect(result.types == expectation.types)

        let encodedValue: String = try encoder.encode(expectation)

        #expect(result == expectation)
        #expect(value == encodedValue)
    }
}
