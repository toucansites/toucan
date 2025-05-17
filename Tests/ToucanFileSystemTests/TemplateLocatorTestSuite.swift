//
//  TemplateLocatorTestSuite.swift
//  Toucan
//
//  Created by Binary Birds on 2025. 03. 12..

import Testing
import Foundation
import FileManagerKitTesting

@testable import ToucanFileSystem

@Suite
struct TemplateLocatorTestSuite {

    @Test()
    func template() async throws {
        try FileManagerPlayground {
            Directory("themes") {
                Directory("default") {
                    Directory("templates") {
                        Directory("foo") {
                            "bar.mustache"
                            "baz.mustache"
                        }
                        "qux.mustache"
                        "quux.md"
                    }
                }
                Directory("overrides") {
                    Directory("templates") {
                        Directory("foo") {
                            "baz.mustache"
                            "lol.mustache"
                        }
                    }
                }
            }
        }
        .test {
            let url = $1.appending(path: "themes/default/templates/")
            let overridesUrl = $1.appending(path: "themes/overrides/templates/")

            let base = $0.find(
                extensions: ["mustache"],
                recursively: true,
                at: url
            )
            let overrides = $0.find(
                extensions: ["mustache"],
                recursively: true,
                at: overridesUrl
            )

            let result: [(id: String, path: String)] = []

            print(base)
            print(overrides)

            //            #expect(
            //                result == [
            //                    .init(id: "foo.bar", path: "foo/bar.mustache"),
            //                    .init(id: "foo.baz", path: "foo/baz.mustache"),
            //                    .init(id: "qux", path: "qux.mustache"),
            //                ]
            //            )
        }
    }
}
