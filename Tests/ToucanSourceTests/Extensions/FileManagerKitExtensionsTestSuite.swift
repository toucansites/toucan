//
//  FileManagerKitExtensionsTestSuite.swift
//  Toucan
//
//  Created by Binary Birds on 2025. 03. 04..

import Testing
import Foundation
import FileManagerKitBuilder

@testable import ToucanSource

@Suite
struct FileManagerKitExtensionsTestSuite {

    @Test()
    func findEmpty() throws {
        try FileManagerPlayground()
            .test {
                let locations = $0.find(at: $1)
                #expect(locations.isEmpty)
            }
    }

    @Test()
    func findAllFiles() throws {
        try FileManagerPlayground {
            Directory(name: "foo") {
                Directory(name: "bar") {
                    "baz.yaml"
                    "qux.yml"
                }
            }
        }
        .test {
            let url = $1.appending(path: "foo/bar/")
            let locations = $0.find(at: url).sorted()

            #expect(locations == ["baz.yaml", "qux.yml"])
        }
    }

    @Test()
    func findDirectoriesAndFiles() throws {
        try FileManagerPlayground {
            Directory(name: "foo") {
                Directory(name: "bar")
                "baz.yaml"
                "qux.yml"
            }
        }
        .test {
            let url = $1.appending(path: "foo/")
            let locations = $0.find(at: url).sorted()

            #expect(locations == ["bar", "baz.yaml", "qux.yml"])
        }
    }

    @Test()
    func findMultipleExtensions() async throws {
        try FileManagerPlayground {
            Directory(name: "foo") {
                Directory(name: "bar") {
                    "baz.yaml"
                    "qux.yml"
                    "quux.txt"
                }
            }
        }
        .test {
            let url = $1.appending(path: "foo/bar/")
            let locations =
                $0.find(
                    extensions: [
                        "yml",
                        "yaml",
                    ],
                    at: url
                )
                .sorted()

            #expect(locations == ["baz.yaml", "qux.yml"])
        }
    }
}
