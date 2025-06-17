//
//  BuildTargetSourceValidatorTestSuite.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 05. 23..
//
//
import Foundation
import Logging
import Testing
import ToucanCore
@testable import ToucanSDK
import ToucanSource

@Suite
struct BuildTargetSourceValidatorTestSuite {
    @Test
    func emptyContentTypes() throws {
        let buildTargetSource = BuildTargetSource(
            locations: .init(
                sourceURL: .init(filePath: ""),
                config: .defaults
            )
        )

        let validator = BuildTargetSourceValidator(
            buildTargetSource: buildTargetSource
        )

        do {
            try validator.validate()
        }
        catch {
            guard case .noDefaultContentType = error else {
                Issue.record("Invalid error.")
                return
            }
        }
    }

    @Test
    func noDefaultContentType() throws {
        let buildTargetSource = BuildTargetSource(
            locations: .init(
                sourceURL: .init(filePath: ""),
                config: .defaults
            ),
            types: [
                .init(id: "foo"),
                .init(id: "bar"),
            ]
        )

        let validator = BuildTargetSourceValidator(
            buildTargetSource: buildTargetSource
        )

        do {
            try validator.validate()
        }
        catch {
            guard case .noDefaultContentType = error else {
                Issue.record("Invalid error.")
                return
            }
        }
    }

    @Test
    func multipleDefaultContentTypes() throws {
        let buildTargetSource = BuildTargetSource(
            locations: .init(
                sourceURL: .init(filePath: ""),
                config: .defaults
            ),
            types: [
                .init(
                    id: "foo",
                    default: true
                ),
                .init(
                    id: "bar",
                    default: true
                ),
            ]
        )

        let validator = BuildTargetSourceValidator(
            buildTargetSource: buildTargetSource
        )

        do {
            try validator.validate()
        }
        catch {
            guard case let .multipleDefaultContentTypes(values) = error else {
                Issue.record("Invalid error.")
                return
            }
            #expect(values == ["foo", "bar"].sorted())
        }
    }
}
