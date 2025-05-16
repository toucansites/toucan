//
//  FileLocatorTestSuite.swift
//  Toucan
//
//  Created by Binary Birds on 2025. 03. 04..

import Testing
import Foundation
@testable import ToucanFileSystem
@testable import FileManagerKitTesting

@Suite
struct FileLocatorTestSuite {

    @Test()
    func fileLocator_emptyRootDirectory() async throws {
        try FileManagerPlayground()
            .test {
                let locations = $0.find(at: $1)
                #expect(locations.isEmpty)
            }
    }

    @Test()
    func fileLocator_allFiles() async throws {
        try FileManagerPlayground {
            Directory("foo") {
                Directory("bar") {
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
    func fileLocator_directoriesAndFiles() async throws {
        try FileManagerPlayground {
            Directory("foo") {
                Directory("bar")
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
    func fileLocator_multipleExtensions() async throws {
        try FileManagerPlayground {
            Directory("foo") {
                Directory("bar") {
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
