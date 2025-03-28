//
//  File.swift
//  toucan
//
//  Created by Viasz-Kádi Ferenc on 2025. 02. 28..
//

import Foundation
import Testing
import ToucanModels
import ToucanTesting
import Logging
import FileManagerKitTesting
@testable import ToucanSource
@testable import ToucanSDK

@Suite
struct ContentDefinitionLoaderTestSuite {

    @Test
    func contentDefinitions() throws {
        let logger = Logger(label: "ContentDefinitionLoaderTestSuite")
        try FileManagerPlayground {
            Directory("themes") {
                Directory("default") {
                    Directory("types") {
                        File(
                            "foo.yml",
                            string: """
                                id: foo
                                paths:
                                properties:
                                relations:
                                queries:
                                """
                        )
                        File(
                            "bar.yml",
                            string: """
                                id: bar
                                paths:
                                properties:
                                relations:
                                queries:
                                """
                        )
                    }
                }
            }
        }
        .test {
            let url = $1.appending(path: "themes/default/types/")
            let overridesUrl = $1.appending(path: "themes/overrides/types/")
            let loader = ContentDefinitionLoader(
                url: url,
                overridesUrl: overridesUrl,
                locations: [
                    .init(path: "foo.yml", overridePath: nil),
                    .init(path: "bar.yml", overridePath: nil),
                ],
                decoder: ToucanYAMLDecoder(),
                logger: logger
            )
            let result = try loader.load()

            #expect(
                result == [
                    .init(
                        id: "foo",
                        paths: [],
                        properties: [:],
                        relations: [:],
                        queries: [:]
                    ),
                    .init(
                        id: "bar",
                        paths: [],
                        properties: [:],
                        relations: [:],
                        queries: [:]
                    ),
                ]
            )
        }
    }

    @Test
    func contentDefinitionsOverride() throws {
        let logger = Logger(label: "ContentDefinitionLoaderTestSuite")
        try FileManagerPlayground {
            Directory("themes") {
                Directory("default") {
                    Directory("types") {
                        File(
                            "foo.yml",
                            string: """
                                id: foo
                                paths:
                                properties:
                                relations:
                                queries:
                                """
                        )
                        File("bar.yml", string: "")
                    }
                }
                Directory("overrides") {
                    Directory("types") {
                        File(
                            "bar.yml",
                            string: """
                                id: bar
                                paths:
                                properties:
                                relations:
                                queries:
                                """
                        )
                    }
                }
            }
        }
        .test {
            let url = $1.appending(path: "themes/default/types/")
            let overridesUrl = $1.appending(path: "themes/overrides/types/")
            let loader = ContentDefinitionLoader(
                url: url,
                overridesUrl: overridesUrl,
                locations: [
                    .init(path: "foo.yml", overridePath: nil),
                    .init(path: "bar.yml", overridePath: "bar.yml"),
                ],
                decoder: ToucanYAMLDecoder(),
                logger: logger
            )
            let result = try loader.load()

            #expect(
                result == [
                    .init(
                        id: "foo",
                        paths: [],
                        properties: [:],
                        relations: [:],
                        queries: [:]
                    ),
                    .init(
                        id: "bar",
                        paths: [],
                        properties: [:],
                        relations: [:],
                        queries: [:]
                    ),
                ]
            )
        }
    }
}
