//
//  TemplateLocatorTestSuite.swift
//  Toucan
//
//  Created by Binary Birds on 2025. 03. 12..

import Testing
import Foundation
@testable import ToucanFileSystem
@testable import FileManagerKitTesting

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
            let locator = TemplateLocator(fileManager: $0)
            let result = locator.locate(at: url, overrides: overridesUrl)

            #expect(
                result == [
                    .init(id: "foo.bar", path: "foo/bar.mustache"),
                    .init(id: "foo.baz", path: "foo/baz.mustache"),
                    .init(id: "qux", path: "qux.mustache"),
                ]
            )
        }
    }
}
