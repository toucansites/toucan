//
//  TargetConfigTestSuite.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 05. 15..
//

import Foundation
import Testing
import ToucanSerialization

@testable import ToucanSource

@Suite
struct TargetConfigTestSuite {
    @Test
    func full() throws {
        let data = """
            targets:
              - name: dev
                config: "./dev.yml"
                url: "http://localhost:3000"
                output: "./dist/"
                default: true
              - name: live
                url: "https://example.com"
            """
            .data(using: .utf8)!

        let decoder = ToucanYAMLDecoder()

        let result = try decoder.decode(
            TargetConfig.self,
            from: data
        )

        #expect(result.targets.count == 2)
        #expect(result.default.name == "dev")
        #expect(result.default.isDefault == true)
        #expect(result.targets[1].name == "live")
    }

    @Test
    func defaultFallbackToFirst() throws {
        let data = """
            targets:
              - name: fallback
              - name: another
            """
            .data(using: .utf8)!

        let decoder = ToucanYAMLDecoder()

        let result = try decoder.decode(
            TargetConfig.self,
            from: data
        )

        #expect(result.targets.count == 2)
        #expect(result.default.name == "fallback")
        #expect(result.default.isDefault == true)
    }

    @Test
    func oneDefaultIsValid() throws {
        let data = """
            targets:
              - name: one
                default: true
              - name: two
            """
            .data(using: .utf8)!

        let decoder = ToucanYAMLDecoder()

        let result = try decoder.decode(TargetConfig.self, from: data)

        #expect(result.targets.count == 2)
        #expect(result.default.name == "one")
    }

    @Test
    func noDefaultFallsBackToFirst() throws {
        let data = """
            targets:
              - name: alpha
              - name: beta
            """
            .data(using: .utf8)!

        let decoder = ToucanYAMLDecoder()

        let result = try decoder.decode(TargetConfig.self, from: data)

        #expect(result.targets.count == 2)
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
            .data(using: .utf8)!

        let decoder = ToucanYAMLDecoder()
        #expect(throws: (any Error).self) {
            _ = try decoder.decode(TargetConfig.self, from: data)
        }
    }

    @Test
    func emptyListFallsBackToDefaults() throws {
        let data = """
            targets: []
            """
            .data(using: .utf8)!

        let decoder = ToucanYAMLDecoder()

        let result = try decoder.decode(TargetConfig.self, from: data)

        #expect(!result.targets.isEmpty)
        #expect(result.default == Target.standard)
    }
}
