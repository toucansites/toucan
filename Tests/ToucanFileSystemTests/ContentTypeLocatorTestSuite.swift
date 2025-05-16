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

@Suite
struct ContentTypeLocatorTestSuite {

    @Test()
    func contentType() async throws {
        try FileManagerPlayground {
            Directory("src") {
                Directory("types") {
                    "post.yaml"
                    "tag.yml"
                }
            }
        }
        .test {
            let typesUrl = $1.appending(path: "src/types/")

            let locations = $0.find(
                extensions: ["yml", "yaml"],
                at: typesUrl
            )
            let expected: [String] = [
                "post.yaml",
                "tag.yml",
            ]

            #expect(
                locations.sorted { $0 < $1 } == expected.sorted { $0 < $1 }
            )
        }
    }

    @Test()
    func contentType_empty() async throws {
        try FileManagerPlayground()
            .test {
                let typesUrl = $1.appending(path: "src/types/")
                let locations = $0.find(
                    extensions: ["yml", "yaml"],
                    at: typesUrl
                )
                #expect(locations.isEmpty)
            }
    }
}
