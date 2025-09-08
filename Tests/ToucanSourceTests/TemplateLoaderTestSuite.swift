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
@testable import ToucanCore
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
                                generatorVersion:
                                    value: "1.0.0-beta.6"
                                    type: "upNextMajor"
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
                decoder: ToucanYAMLDecoder()
            )
            let template = try loader.load()

            #expect(template.metadata.generatorVersion.value.description == "1.0.0-beta.6")
            #expect(template.metadata.generatorVersion.type == .upNextMajor)

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

    @Test    
    func defaultGeneratorVersionComparisonType() async throws {
        // TODO: default comp type
    }

    @Test()
    func invalidGeneratorVersion() async throws {
        try FileManagerPlayground {
            Directory(name: "src") {
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
                                generatorVersion:
                                    value: "invalid"
                                    type: "upNextMajor"
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
                    }
                }
            }
        }
        .test {
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
                decoder: ToucanYAMLDecoder()
            )

            do {
                let template = try loader.load()
            }
            catch {
                let error = error as ToucanError

                if let context = error.lookup({
                    if case let DecodingError.dataCorrupted(ctx) = $0 {
                        return ctx
                    }
                    return nil
                }) {
                    let expected = "Invalid semantic version"
                    #expect(context.debugDescription == expected)
                }
                else {
                    throw error
                }

                // Caught error: TemplateLoaderError(type: "Metadata", error: Optional(
                    // ToucanSource.ObjectLoaderError(url: file:///var/folders/bv/3x3g8wn92853hbng2gt7cxtr0000gn/T/FileManagerPlayground_6E69FFEE-3DF7-49E5-B01F-4BC4A715FFCD/src/templates/default/template.yaml, error: Optional(
                    // ToucanSerialization.ToucanDecoderError(type: ToucanSource.Template.Metadata, error: Optional(
                    // Swift.DecodingError.dataCorrupted(
                    // Swift.DecodingError.Context(codingPath: [CodingKeys(stringValue: "generatorVersion", intValue: nil), CodingKeys(stringValue: "value", intValue: nil)], debugDescription: "Invalid semantic version", underlyingError: nil))))))))
                
                // guard case let .invalidVersion(value) = error else {
                //     Issue.record("Expected .invalidVersion error, got: \(error)")
                //     return
                // }
                // #expect(value == "invalid")
            }

            // #expect(template.metadata.generatorVersion.value.description == "1.0.0-beta.6")
            // #expect(template.metadata.generatorVersion.type == .upNextMajor)
        }
    }
}
