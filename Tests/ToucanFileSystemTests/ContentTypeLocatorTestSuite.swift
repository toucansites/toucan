//
//  ContentTypeLocatorTestSuite.swift
//  Toucan
//
//  Created by Binary Birds on 2025. 03. 04..

import Testing
import Foundation
@testable import ToucanFileSystem
@testable import ToucanModels
@testable import FileManagerKitTesting

import Testing

@Suite(.serialized)
struct ContentTypeLocatorTestSuite {

    @Test()
    func contentType() async throws {
        try FileManagerPlayground {
            Directory("default") {
                Directory("types") {
                    "post.yaml"
                    "tag.yml"
                }
            }
            Directory("overrides") {
                Directory("types") {
                    "post.yml"
                    "custom.yml"
                }
            }
        }
        .test {
            let typesUrl = $1.appending(path: "default/types/")
            let overridesUrl = $1.appending(path: "overrides/types/")
            let locator = OverrideFileLocator(fileManager: $0)
            let locations = locator.locate(
                at: typesUrl,
                overrides: overridesUrl
            )
            let expected: [OverrideFileLocation] = [
                .init(path: "post.yaml", overridePath: "post.yml"),
                .init(path: "tag.yml"),
            ]

            #expect(
                locations.sorted { $0.path < $1.path }
                    == expected.sorted { $0.path < $1.path }
            )
        }
    }

    @Test()
    func contentType_empty() async throws {
        try FileManagerPlayground()
            .test {
                let typesUrl = $1.appending(path: "default/types/")
                let overridesUrl = $1.appending(path: "overrides/types/")
                let locator = OverrideFileLocator(fileManager: $0)
                let locations = locator.locate(
                    at: typesUrl,
                    overrides: overridesUrl
                )

                #expect(locations.isEmpty)
            }
    }

    @Test()
    func contentType_onlyOverride() async throws {
        try FileManagerPlayground {
            Directory("overrides") {
                Directory("types") {
                    "post.yml"
                    "custom.yml"
                }
            }
        }
        .test {
            let typesUrl = $1.appending(path: "default/types/")
            let overridesUrl = $1.appending(path: "overrides/types/")
            let locator = OverrideFileLocator(fileManager: $0)
            let locations = locator.locate(
                at: typesUrl,
                overrides: overridesUrl
            )

            #expect(locations.isEmpty)
        }
    }

    @Test()
    func contentType_noOverrides() async throws {
        try FileManagerPlayground {
            Directory("default") {
                Directory("types") {
                    "post.yaml"
                    "tag.yml"
                }
            }
        }
        .test {
            let typesUrl = $1.appending(path: "default/types/")
            let overridesUrl = $1.appending(path: "overrides/types/")
            let locator = OverrideFileLocator(fileManager: $0)
            let locations = locator.locate(
                at: typesUrl,
                overrides: overridesUrl
            )
            let expected: [OverrideFileLocation] = [
                .init(path: "post.yaml"),
                .init(path: "tag.yml"),
            ]

            #expect(
                locations.sorted { $0.path < $1.path }
                    == expected.sorted { $0.path < $1.path }
            )
        }
    }
}
