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
        let items:
            [(
                String,
                Template.Metadata.GeneratorVersion.ComparisonType,
                String
            )] = [
                // .exact
                ("1.0.0-beta.6", .exact, "1.0.0-beta.6"),
                ("1.2.0", .exact, "1.2.0"),

                // .upNextMinor
                ("1.0.0-beta.6", .upNextMinor, "1.0.0"),
                ("1.0.0-beta.6", .upNextMinor, "1.0.0-rc.1"),
                ("1.0.0", .upNextMinor, "1.0.1"),

                // .upNextMajor
                ("1.0.0-beta.6", .upNextMajor, "1.0.0"),
                ("1.0.0-beta.6", .upNextMajor, "1.0.0-rc.1"),
                ("1.0.0", .upNextMajor, "1.0.1"),
                ("1.0.0", .upNextMajor, "1.2.0"),
            ]

        for item in items {
            let generatorVersion = Version(item.0)!
            let toucanVersion = Version(item.2)!

            let templateValidator = try TemplateValidator(
                generatorInfo: .init(version: toucanVersion.description)
            )

            try templateValidator.validate(
                Mocks.Templates.example(
                    generatorVersion: .init(
                        value: generatorVersion,
                        type: item.1
                    )
                )
            )
        }
    }

    @Test
    func unsupportedVersion() throws {
        let items:
            [(
                String,
                Template.Metadata.GeneratorVersion.ComparisonType,
                String
            )] = [
                // .exact
                ("1.0.0", .exact, "1.0.0-beta.1"),
                ("2.0.1", .exact, "2.0.0"),

                // .upNextMinor
                ("1.0.0", .upNextMinor, "1.0.1"),
                ("1.0.0", .upNextMinor, "1.0.2-beta.1"),
                ("1.0.0", .upNextMinor, "1.1.0"),
                ("1.0.0", .upNextMinor, "1.0.2-beta.1"),
                ("1.0.0", .upNextMinor, "2.0.0"),
                ("1.0.0-beta.6", .upNextMinor, "1.0.0-rc.1"),
                ("1.1.1", .upNextMinor, "1.0.0"),

                // .upNextMajor
                ("1.0.0", .upNextMajor, "1.0.1"),
                ("1.0.0", .upNextMajor, "1.2.0"),
                ("1.0.0", .upNextMajor, "1.5.0-beta.2"),
                ("1.0.0", .upNextMajor, "2.0.0"),
                ("2.0.0", .upNextMajor, "1.0.0"),
                ("1.5.0", .upNextMajor, "1.0.0-beta.3"),
            ]

        for item in items {
            let generatorVersion = Version(item.0)!
            let toucanVersion = Version(item.2)!

            let templateValidator = try TemplateValidator(
                generatorInfo: .init(version: toucanVersion.description)
            )

            do {
                try templateValidator.validate(
                    Mocks.Templates.example(
                        generatorVersion: .init(
                            value: generatorVersion,
                            type: item.1
                        )
                    )
                )
            }
            catch {
                guard
                    case let .unsupportedGeneratorVersion(
                        version,
                        currentVersion
                    ) = error
                else {
                    Issue.record(
                        "Expected .unsupportedGeneratorVersion error, got: \(error)"
                    )
                    return
                }

                #expect(version.value == generatorVersion)
                #expect(currentVersion == toucanVersion)
            }
        }
    }
}
