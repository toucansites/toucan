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

import Version

@Suite
struct TemplateValidatorTestSuite {

    @Test
    func valid() throws {
        let version = Version("1.0.0-beta.6")!
        let templateValidator = try TemplateValidator(
            generatorInfo: .init(version: version.description)
        )

        try templateValidator.validate(
            Mocks.Templates.example(
                generatorVersion: .init(value: version, type: .exact)
            )
        )
    }

    @Test
    func unsupportedVersion() throws {
        let templateValidator = try TemplateValidator(
            generatorInfo: .init(version: "1.2.0")
        )

        do {
            try templateValidator.validate(
                Mocks.Templates.example(
                    generatorVersion:
                        .init(value: Version("1.0.0")!, type: .upNextMinor)
                )
            )
        }
        catch {
            guard
                case let .unsupportedGeneratorVersion(
                    generatorVersion,
                    currentVersion
                ) = error
            else {
                Issue.record(
                    "Expected .unsupportedGeneratorVersion error, got: \(error)"
                )
                return
            }

            #expect(generatorVersion.value.description == "1.0.0")
            #expect(currentVersion.description == "1.2.0")
        }
    }
}
