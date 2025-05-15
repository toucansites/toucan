//
//  TargetsDecodingTestSuite.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 05. 15..
//

import Foundation
import Testing
import ToucanModels
import ToucanSerialization

@Suite
struct TargetsDecodingTestSuite {

    @Test
    func full() throws {
        let data = """
            targets:
              - name: dev
                config: "./dev.yml"
                url: "http://localhost:3000"
                locale: "en-US"
                timeZone: "Europe/Budapest"
                output: "./docs/"
                default: true
              - name: live
                url: "https://example.com"
                locale: "en-GB"
            """
            .dataValue()

        let decoder = ToucanYAMLDecoder()

        let result = try decoder.decode(
            Targets.self,
            from: data
        )

        #expect(result.all.count == 2)
        #expect(result.default.name == "dev")
        #expect(result.default.isDefault == true)
        #expect(result.all[1].name == "live")
    }

    @Test
    func defaultFallbackToFirst() throws {
        let data = """
            targets:
              - name: fallback
              - name: another
            """
            .dataValue()

        let decoder = ToucanYAMLDecoder()

        let result = try decoder.decode(
            Targets.self,
            from: data
        )

        #expect(result.all.count == 2)
        #expect(result.default.name == "fallback")
        #expect(result.default.isDefault == true)
    }

    @Test
    func missingKeyFallback() throws {
        let data = """
            irrelevant: true
            """
            .dataValue()

        let decoder = ToucanYAMLDecoder()

        let result = try decoder.decode(
            Targets.self,
            from: data
        )

        #expect(result.all.count == 1)
        #expect(result.default.name == "dev")
    }

    @Test
    func oneDefaultIsValid() throws {
        let data = """
            targets:
              - name: one
                default: true
              - name: two
            """
            .dataValue()

        let decoder = ToucanYAMLDecoder()

        let result = try decoder.decode(Targets.self, from: data)

        #expect(result.all.count == 2)
        #expect(result.default.name == "one")
    }

    @Test
    func noDefaultFallsBackToFirst() throws {
        let data = """
            targets:
              - name: alpha
              - name: beta
            """
            .dataValue()

        let decoder = ToucanYAMLDecoder()

        let result = try decoder.decode(Targets.self, from: data)

        #expect(result.all.count == 2)
        #expect(result.default.name == "alpha")
        #expect(result.default.isDefault == true)
    }

    @Test
    func multipleDefaultsThrows() throws {
        let data = """
            targets:
              - name: foo
                default: true
              - name: bar
                default: true
            """
            .dataValue()

        let decoder = ToucanYAMLDecoder()
        #expect(throws: (any Error).self) {
            _ = try decoder.decode(Targets.self, from: data)
        }
    }

    @Test
    func emptyListFallsBackToDefaults() throws {
        let data = """
            targets: []
            """
            .dataValue()

        let decoder = ToucanYAMLDecoder()

        let result = try decoder.decode(Targets.self, from: data)

        #expect(!result.all.isEmpty)
        #expect(result.default == Target.default)
    }

    @Test
    func missingTargetsKeyFallsBackToDefaults() throws {
        let data = """
            unrelated: true
            """
            .dataValue()

        let decoder = ToucanYAMLDecoder()

        let result = try decoder.decode(Targets.self, from: data)

        #expect(result.all.count == 1)
        #expect(result.default.name == "dev")
    }
}
