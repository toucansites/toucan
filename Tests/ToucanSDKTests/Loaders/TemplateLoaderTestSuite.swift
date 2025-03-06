//
//  File.swift
//  toucan
//
//  Created by Viasz-Kádi Ferenc on 2025. 02. 28..
//

import Foundation
import Testing
import ToucanContent
import ToucanModels
import ToucanTesting
import FileManagerKitTesting
@testable import ToucanSource
@testable import ToucanSDK
@testable import ToucanFileSystem

@Suite
struct TemplateLoaderTestSuite {

    @Test
    func loadTemplates() throws {

        try FileManagerPlayground {
            Directory("themes") {
                Directory("default") {
                    Directory("templates") {
                        File(
                            "sitemap.mustache",
                            string: Templates.Mocks.sitemap()
                        )
                        File(
                            "redirect.mustache",
                            string: Templates.Mocks.redirect()
                        )
                    }
                }
            }
        }
        .test {
            let url = $1.appending(path: "themes/default/templates/")
            let overridesUrl = $1.appending(path: "themes/overrides/templates/")

            let locator = TemplateLocator(fileManager: $0)
            let locatorResults = locator.locate(
                at: url,
                overridesUrl: overridesUrl
            )

            let loader = TemplateLoader(
                url: url,
                overridesUrl: overridesUrl,
                locations: locatorResults,
                logger: .init(label: "TemplateLoaderTestSuite")
            )
            let results = try loader.load()

            #expect(results.count == 2)
        }
    }

    @Test
    func loadTemplatesOverride() throws {

        try FileManagerPlayground {
            Directory("themes") {
                Directory("default") {
                    Directory("templates") {
                        File(
                            "sitemap.mustache",
                            string: Templates.Mocks.sitemap()
                        )
                        File("redirect.mustache", string: "")
                    }
                }
                Directory("overrides") {
                    Directory("templates") {
                        File(
                            "redirect.mustache",
                            string: Templates.Mocks.redirect()
                        )
                    }
                }
            }
        }
        .test {
            let url = $1.appending(path: "themes/default/templates/")
            let overridesUrl = $1.appending(path: "themes/overrides/templates/")

            let locator = TemplateLocator(fileManager: $0)
            let locatorResults = locator.locate(
                at: url,
                overridesUrl: overridesUrl
            )

            let loader = TemplateLoader(
                url: url,
                overridesUrl: overridesUrl,
                locations: locatorResults,
                logger: .init(label: "TemplateLoaderTestSuite")
            )
            let results = try loader.load()

            #expect(results.count == 2)
        }
    }

}
