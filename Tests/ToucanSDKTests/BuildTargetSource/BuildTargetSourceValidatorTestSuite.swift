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
            Issue.record("Should trigger an error.")
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
            Issue.record("Should trigger an error.")
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
            Issue.record("Should trigger an error.")
        }
        catch {
            guard case let .multipleDefaultContentTypes(values) = error else {
                Issue.record("Invalid error.")
                return
            }
            #expect(values == ["foo", "bar"].sorted())
        }
    }

    @Test
    func invalidOriginPath() throws {
        let buildTargetSource = BuildTargetSource(
            locations: .init(
                sourceURL: .init(filePath: ""),
                config: .defaults
            ),
            types: [
                .init(
                    id: "page",
                    default: true
                )
            ],
            rawContents: [
                .init(
                    origin: .init(
                        path: .init("foo?bar"),
                        slug: "foo-bar"
                    ),
                    lastModificationDate: Date().timeIntervalSinceNow,
                    assetsPath: "",
                    assets: []
                )
            ]
        )

        let validator = BuildTargetSourceValidator(
            buildTargetSource: buildTargetSource
        )

        do {
            try validator.validate()
            Issue.record("Should trigger an error.")
        }
        catch {
            guard case let .invalidRawContentOriginPath(path) = error else {
                Issue.record("Invalid error.")
                return
            }
            #expect(path == "foo?bar")
        }
    }

}
