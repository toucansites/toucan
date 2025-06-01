//
//  ThemeLoaderTestSuite.swift
//  Toucan
//
//  Created by Binary Birds on 2025. 03. 12..

import Testing
import Foundation
import ToucanSerialization
import FileManagerKit
import FileManagerKitBuilder
import Logging

@testable import ToucanSource

@Suite
struct ThemeLoaderTestSuite {

    @Test()
    func standardThemeLoading() async throws {
        try FileManagerPlayground {
            Directory(name: "src") {
                Directory(name: "assets") {
                    "style.css"
                }
                Directory(name: "contents") {
                    Directory(name: "about") {
                        File(
                            name: "pages.about.mustache",
                            string: """
                                about content override
                                """
                        )
                    }
                }
                Directory(name: "themes") {
                    Directory(name: "default") {
                        Directory(name: "assets") {
                            "theme.css"
                        }
                        Directory(name: "templates") {
                            Directory(name: "pages") {
                                File(
                                    name: "default.mustache",
                                    string: """
                                        default
                                        """
                                )
                                File(
                                    name: "about.mustache",
                                    string: """
                                        about
                                        """
                                )
                                File(
                                    name: "test.html",
                                    string: """
                                        test.html
                                        """
                                )
                            }
                            File(
                                name: "html.mustache",
                                string: """
                                    html
                                    """
                            )
                            "README.md"
                        }
                        "README.md"
                    }
                    Directory(name: "overrides") {
                        Directory(name: "default") {
                            Directory(name: "assets") {
                                "theme.css"
                            }
                            Directory(name: "templates") {
                                Directory(name: "pages") {
                                    File(
                                        name: "default.mustache",
                                        string: """
                                            default override
                                            """
                                    )
                                    File(
                                        name: "about.mustache",
                                        string: """
                                            about override
                                            """
                                    )
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
                theme.components.templates.map(\.path).sorted()
                    == [
                        "pages/default.mustache",
                        "pages/about.mustache",
                        "pages/test.html",
                        "html.mustache",
                    ]
                    .sorted()
            )

            #expect(
                theme.overrides.assets.sorted()
                    == [
                        "theme.css"
                    ]
                    .sorted()
            )
            #expect(
                theme.overrides.templates.map(\.path).sorted()
                    == [
                        "pages/about.mustache",
                        "pages/default.mustache",
                    ]
                    .sorted()
            )

            #expect(
                theme.content.assets.sorted()
                    == [
                        "style.css"
                    ]
                    .sorted()
            )
            #expect(
                theme.content.templates.map(\.path).sorted()
                    == [
                        "about/pages.about.mustache"
                    ]
                    .sorted()
            )

            let results = loader.getTemplatesIDsWithContents(theme)

            let exp: [String: String] = [
                "pages.test": "test.html",
                "pages.about": "about content override",
                "pages.default": "default override",
                "html": "html",
            ]

            #expect(
                results
                    == .init(
                        uniqueKeysWithValues: exp.sorted { $0.key < $1.key }
                    )
            )

        }
    }
}
