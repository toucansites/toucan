//
//  TargetTestSuite.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 05. 15..

import Foundation
import Testing
import ToucanSerialization

@testable import ToucanSource

@Suite
struct TargetTestSuite {

    @Test
    func full() throws {
        let data = """
            name: "dev"
            config: "./some-config.yml"
            url: "https://example.com"
            locale: "en-GB"
            timeZone: "Europe/London"
            output: "./out"
            default: true
            """
            .data(using: .utf8)!

        let decoder = ToucanYAMLDecoder()

        let result = try decoder.decode(
            Target.self,
            from: data
        )

        #expect(result.name == "dev")
        #expect(result.config == "./some-config.yml")
        #expect(result.url == "https://example.com")
        #expect(result.locale == "en-GB")
        #expect(result.timeZone == "Europe/London")
        #expect(result.output == "./out")
        #expect(result.isDefault == true)
    }

    @Test
    func defaults() throws {
        let data = """
            name: "dev"
            """
            .data(using: .utf8)!

        let decoder = ToucanYAMLDecoder()

        let result = try decoder.decode(
            Target.self,
            from: data
        )

        #expect(result.name == "dev")
        #expect(result.config == "")
        #expect(result.url == "http://localhost:3000")
        #expect(result.locale == "en-US")
        #expect(result.timeZone == "UTC")
        #expect(result.output == "docs")
        #expect(result.isDefault == false)
    }
}
