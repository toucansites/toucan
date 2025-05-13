//
//  ContentDefinitionLoaderTestSuite.swift
//  Toucan
//
//  Created by Viasz-Kádi Ferenc on 2025. 02. 28..
//

import Foundation
import Testing
import ToucanModels
import ToucanTesting
import Logging
import FileManagerKitTesting
import ToucanSerialization
@testable import ToucanSource
@testable import ToucanSDK

@Suite
struct ContentDefinitionLoaderTestSuite {

    @Test
    func contentDefinitions() throws {
        try FileManagerPlayground {
            Directory("src") {
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
        .test {
            let url = $1.appending(path: "src/types/")
            let loader = ContentDefinitionLoader(
                url: url,
                locations: [
                    "foo.yml",
                    "bar.yml",
                ],
                decoder: ToucanYAMLDecoder()
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
