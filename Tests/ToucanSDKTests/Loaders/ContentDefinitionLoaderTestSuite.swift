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
import FileManagerKitTesting
@testable import ToucanSource
@testable import ToucanSDK

@Suite
struct ContentDefinitionLoaderTestSuite {

    @Test
    func contentDefinitions() throws {
        try FileManagerPlayground {
            Directory("themes") {
                Directory("default") {
                    Directory("types") {
                        File(
                            "foo.yml",
                            string: """
                                type: foo
                                paths:
                                properties:
                                relations:
                                queries:
                                """
                        )
                        File(
                            "bar.yml",
                            string: """
                                type: bar
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
                logger: .init(label: "ContentTypeLoaderTests")
            )
            let result = try loader.load()

            #expect(
                result == [
                    .init(
                        type: "foo",
                        paths: [],
                        properties: [:],
                        relations: [:],
                        queries: [:]
                    ),
                    .init(
                        type: "bar",
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
        try FileManagerPlayground {
            Directory("themes") {
                Directory("default") {
                    Directory("types") {
                        File(
                            "foo.yml",
                            string: """
                                type: foo
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
                                type: bar
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
                logger: .init(label: "ContentTypeLoaderTests")
            )
            let result = try loader.load()

            #expect(
                result == [
                    .init(
                        type: "foo",
                        paths: [],
                        properties: [:],
                        relations: [:],
                        queries: [:]
                    ),
                    .init(
                        type: "bar",
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
