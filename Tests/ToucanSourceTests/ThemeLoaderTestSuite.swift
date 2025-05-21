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
    func template() async throws {
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

            let loader = ThemeLoader(locations: locations)

            let assets = $0.find(
                recursively: true,
                at: locations.currentThemeAssetsUrl
            )
            let templates = $0.find(
                extensions: ["mustache"],
                recursively: true,
                at: locations.currentThemeTemplatesUrl
            )

            let assetOverrides = $0.find(
                recursively: true,
                at: locations.currentThemeAssetOverridesUrl
            )

            let templateOverrides = $0.find(
                extensions: ["mustache"],
                recursively: true,
                at: locations.currentThemeTemplateOverridesUrl
            )

            let contentAssetOverrides = $0.find(
                recursively: true,
                at: locations.siteAssetsUrl
            )

            let contentTemplateOverrides = $0.find(
                extensions: ["mustache"],
                recursively: true,
                at: locations.contentsUrl
            )

            let theme = Theme(
                name: config.themes.current.path,
                location: locations.themesUrl,
                components: .init(
                    assets: assets,
                    templates: templates.map { .init(path: $0) }
                ),
                overrides: .init(
                    assets: assetOverrides,
                    templates: templateOverrides.map { .init(path: $0) }
                ),
                content: .init(
                    assets: contentAssetOverrides,
                    templates: contentTemplateOverrides.map { .init(path: $0) }
                )
            )

            dump(theme)

            //            #expect(
            //                result == [
            //                    .init(id: "foo.bar", path: "foo/bar.mustache"),
            //                    .init(id: "foo.baz", path: "foo/baz.mustache"),
            //                    .init(id: "qux", path: "qux.mustache"),
            //                ]
            //            )
        }
    }

    //    @Test
    //    func loadTemplates() throws {
    //        let logger = Logger(label: "TemplateLoaderTestSuite")
    //        try FileManagerPlayground {
    //            Directory("themes") {
    //                Directory("default") {
    //                    Directory("templates") {
    //                        File(
    //                            "sitemap.mustache",
    //                            string: Templates.Mocks.sitemap()
    //                        )
    //                        File(
    //                            "redirect.mustache",
    //                            string: Templates.Mocks.redirect()
    //                        )
    //                    }
    //                }
    //            }
    //        }
    //        .test {
    //            let url = $1.appending(path: "themes/default/templates/")
    //            let overridesUrl = $1.appending(path: "themes/overrides/templates/")
    //
    //            let locator = TemplateLocator(fileManager: $0)
    //            let locations = locator.locate(at: url, overrides: overridesUrl)
    //
    //            let loader = TemplateLoader(
    //                url: url,
    //                overridesUrl: overridesUrl,
    //                locations: locations,
    //                logger: logger
    //            )
    //            let results = try loader.load()
    //
    //            #expect(results.count == 2)
    //        }
    //    }
    //
    //    @Test
    //    func loadTemplatesOverride() throws {
    //        let logger = Logger(label: "TemplateLoaderTestSuite")
    //        try FileManagerPlayground {
    //            Directory("themes") {
    //                Directory("default") {
    //                    Directory("templates") {
    //                        File(
    //                            "sitemap.mustache",
    //                            string: Templates.Mocks.sitemap()
    //                        )
    //                        File("redirect.mustache", string: "")
    //                    }
    //                }
    //                Directory("overrides") {
    //                    Directory("templates") {
    //                        File(
    //                            "redirect.mustache",
    //                            string: Templates.Mocks.redirect()
    //                        )
    //                    }
    //                }
    //            }
    //        }
    //        .test {
    //            let url = $1.appending(path: "themes/default/templates/")
    //            let overridesUrl = $1.appending(path: "themes/overrides/templates/")
    //
    //            let locator = TemplateLocator(fileManager: $0)
    //            let locations = locator.locate(at: url, overrides: overridesUrl)
    //
    //            let loader = TemplateLoader(
    //                url: url,
    //                overridesUrl: overridesUrl,
    //                locations: locations,
    //                logger: logger
    //            )
    //            let results = try loader.load()
    //
    //            #expect(results.count == 2)
    //        }
    //    }
}
