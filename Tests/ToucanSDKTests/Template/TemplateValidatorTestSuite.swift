//
//  TemplateValidatorTestSuite.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 05. 23..
//
//
import Foundation
import Logging
import Testing
@testable import ToucanCore
@testable import ToucanSDK
@testable import ToucanSource

@Suite
struct TemplateValidatorTestSuite {

    @Test
    func valid() throws {
        let templateValidator = try TemplateValidator(
            generatorInfo: .init(version: "1.0.0-beta.5")
        )

        try templateValidator.validate(
            Mocks.Templates.example(
                generatorVersions: [
                    "1.0.0-beta.5",
                    "1.0.0-beta.4",
                    "1.0.0",
                ]
            )
        )
    }

    @Test
    func invalidVersion() throws {
        let templateValidator = try TemplateValidator()

        do {
            try templateValidator.validate(
                Mocks.Templates.example(generatorVersions: ["invalid"])
            )
        }
        catch {
            guard case let .invalidVersion(value) = error else {
                Issue.record("Expected .invalidVersion error, got: \(error)")
                return
            }
            #expect(value == "invalid")
        }
    }

    @Test
    func unsupportedVersion() throws {
        let templateValidator = try TemplateValidator(
            generatorInfo: .init(version: "1.0.0-beta.5")
        )

        do {
            try templateValidator.validate(
                Mocks.Templates.example(
                    generatorVersions: [
                        "1.0.0",
                        "1.0.0-beta.5",
                        "2.0.0",
                    ]
                )
            )
        }
        catch {
            guard
                case let .noSupportedGeneratorVersion(version, supported) =
                    error
            else {
                Issue.record(
                    "Expected .noSupportedGeneratorVersion error, got: \(error)"
                )
                return
            }

            #expect(version.description == "1.0.0-beta.5")
            #expect(
                supported.map {
                    $0.description
                } == ["1.0.0-beta.5", "1.0.0", "2.0.0"]
            )
        }
    }
}
