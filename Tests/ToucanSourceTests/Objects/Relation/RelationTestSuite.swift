//
//  RelationTestSuite.swift
//  Toucan
//
//  Created by Binary Birds on 2025. 03. 12..

import Foundation
import Testing
import ToucanSerialization

@testable import ToucanSource

@Suite
struct RelationTestSuite {

    // MARK: - order

    @Test
    func basicOrdering() throws {
        let data = """
            references: post
            type: many
            order: 
                key: title
                direction: desc
            """
            .data(using: .utf8)!

        let decoder = ToucanYAMLDecoder()

        let result = try decoder.decode(
            Relation.self,
            from: data
        )

        #expect(result.references == "post")
        #expect(result.type == .many)
        #expect(result.order?.key == "title")
        #expect(result.order?.direction == .desc)
    }

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
            dateFormats:
              input:
                format: ymd
              output:
                test1:
                  format: his
                  locale: en-US
                  timeZone: EST
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
            themes:
              assets:
                path: custom7
              current:
                path: custom8
              location:
                path: custom9
              overrides:
                path: custom10
              templates:
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
        expectation.dateFormats.input = .init(
            localization: .defaults,
            format: "ymd"
        )
        expectation.dateFormats.output["test1"] = .init(
            localization: .init(
                locale: "en-US",
                timeZone: "EST",
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
        expectation.themes.assets.path = "custom7"
        expectation.themes.current.path = "custom8"
        expectation.themes.location.path = "custom9"
        expectation.themes.overrides.path = "custom10"
        expectation.themes.templates.path = "custom11"
        expectation.types.path = "custom12"

        #expect(result.blocks == expectation.blocks)
        #expect(result.contents == expectation.contents)
        #expect(result.dateFormats == expectation.dateFormats)
        #expect(result.pipelines == expectation.pipelines)
        #expect(result.renderer == expectation.renderer)
        #expect(result.site == expectation.site)
        #expect(result.themes == expectation.themes)
        #expect(result.types == expectation.types)

        let encodedValue: String = try encoder.encode(expectation)

        #expect(result == expectation)
        #expect(value == encodedValue)
    }
}
