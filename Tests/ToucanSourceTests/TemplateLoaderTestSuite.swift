//
//  TemplateLoaderTestSuite.swift
//  Toucan
//
//  Created by Binary Birds on 2025. 03. 12..

import FileManagerKit
import FileManagerKitBuilder
import Foundation
import Logging
import Testing
import ToucanSerialization

@testable import ToucanSource

@Suite
struct TemplateLoaderTestSuite {

    @Test()
    func standardTemplateLoading() async throws {
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
                Directory(name: "templates") {
                    Directory(name: "default") {
                        File(
                            name: "template.yaml",
                            string: """
                                author:
                                    name: Test Template Author
                                    url: http://localhost:8080/
                                demo:
                                    url: http://localhost:8080/
                                description: Test Template description
                                generatorVersions:
                                    - 1.0.0-beta.5
                                license:
                                    name: Test License
                                    url: http://localhost:8080/
                                name: Test Template
                                tags:
                                    - blog
                                    - adaptive-colors
                                url: http://localhost:8080/
                                version: 1.0.0
                                """
                        )
                        Directory(name: "assets") {
                            "template.css"
                        }
                        Directory(name: "views") {
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
                                "template.css"
                            }
                            Directory(name: "views") {
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
            var logger = Logger(label: "test")
            logger.logLevel = .trace

            let sourceURL = $1.appending(path: "src/")
            let config = Config.defaults
            let locations = BuiltTargetSourceLocations(
                sourceURL: sourceURL,
                config: config
            )

            let loader = TemplateLoader(
                locations: locations,
                fileManager: $0,
                encoder: ToucanYAMLEncoder(),
                decoder: ToucanYAMLDecoder(),
                logger: logger
            )
            let template = try loader.load()

            #expect(
                template.components.assets.sorted()
                    == [
                        "template.css"
                    ]
                    .sorted()
            )
            #expect(
                template.components.views.map(\.path).sorted()
                    == [
                        "pages/default.mustache",
                        "pages/about.mustache",
                        "pages/test.html",
                        "html.mustache",
                    ]
                    .sorted()
            )

            #expect(
                template.overrides.assets.sorted()
                    == [
                        "template.css"
                    ]
                    .sorted()
            )
            #expect(
                template.overrides.views.map(\.path).sorted()
                    == [
                        "pages/about.mustache",
                        "pages/default.mustache",
                    ]
                    .sorted()
            )

            #expect(
                template.content.assets.sorted()
                    == [
                        "style.css"
                    ]
                    .sorted()
            )
            #expect(
                template.content.views.map(\.path).sorted()
                    == [
                        "about/pages.about.mustache"
                    ]
                    .sorted()
            )

            let results = template.getViewIDsWithContents()

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
