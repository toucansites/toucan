//
//  ThemeLoaderTestSuite.swift
//  Toucan
//
//  Created by Binary Birds on 2025. 03. 12..

import Testing
import Foundation
import ToucanSerialization
import FileManagerKit
import FileManagerKitTesting
import Logging

@testable import ToucanSource

@Suite
struct ThemeLoaderTestSuite {

    @Test()
    func standardThemeLoading() async throws {
        try FileManagerPlayground {
            Directory("src") {
                Directory("assets") {
                    "style.css"
                }
                Directory("contents") {
                    Directory("about") {
                        "about.mustache"
                    }
                }
                Directory("themes") {
                    Directory("default") {
                        Directory("assets") {
                            "theme.css"
                        }
                        Directory("templates") {
                            Directory("pages") {
                                "default.mustache"
                                "about.mustache"
                                "test.html"
                            }
                            "html.mustache"
                            "README.md"
                        }
                        "README.md"
                    }
                    Directory("overrides") {
                        Directory("default") {
                            Directory("assets") {
                                "theme.css"
                            }
                            Directory("templates") {
                                Directory("pages") {
                                    "default.mustache"
                                }
                                "README.md"
                            }
                            "README.md"
                        }
                    }
                }
            }
        }
        .test {
            let sourceURL = $1.appending(path: "src/")
            let config = Config.defaults
            let locations = BuiltTargetSourceLocations(
                sourceUrl: sourceURL,
                config: config
            )

            let loader = ThemeLoader(
                locations: locations,
                fileManager: $0
            )
            let theme = try loader.load()

            #expect(theme.baseUrl == locations.themesUrl)

            #expect(
                theme.components.assets.sorted()
                    == [
                        "theme.css"
                    ]
                    .sorted()
            )
            #expect(
                theme.components.templates.sorted(by: { $0.id < $1.id })
                    == [
                        .init(path: "pages/default.mustache"),
                        .init(path: "pages/about.mustache"),
                        .init(path: "pages/test.html"),
                        .init(path: "html.mustache"),
                    ]
                    .sorted(by: { $0.id < $1.id })
            )

            #expect(
                theme.overrides.assets.sorted()
                    == [
                        "theme.css"
                    ]
                    .sorted()
            )
            #expect(
                theme.overrides.templates.sorted(by: { $0.id < $1.id })
                    == [
                        .init(path: "pages/default.mustache")
                    ]
                    .sorted(by: { $0.id < $1.id })
            )

            #expect(
                theme.content.assets.sorted()
                    == [
                        "style.css"
                    ]
                    .sorted()
            )
            #expect(
                theme.content.templates.sorted(by: { $0.id < $1.id })
                    == [
                        .init(path: "about/about.mustache")
                    ]
                    .sorted(by: { $0.id < $1.id })
            )
        }
    }
}
