//
//  File.swift
//  toucan
//
//  Created by Viasz-Kádi Ferenc on 2025. 02. 20..
//

import Foundation
import Testing
import ToucanModels
import ToucanTesting
import ToucanContent
import Logging
@testable import ToucanSource

@Suite
struct SourceBundleRedirectTestSuite {

    @Test
    func redirect() throws {
        let now = Date()
        let logger = Logger(label: "SourceBundleRedirectTestSuite")

        let formatter = DateFormatter()
        formatter.locale = .init(identifier: "en_US")
        formatter.timeZone = .init(secondsFromGMT: 0)
        formatter.dateFormat = "Y-MM-dd"

        let pipelines = [
            Pipeline.Mocks.redirect()
        ]

        let pageDefinition = ContentDefinition.Mocks.page()
        let rawPageContents = RawContent.Mocks.pages(max: 2)
        let pageContents = rawPageContents.map {
            let converter = ContentDefinitionConverter(
                contentDefinition: pageDefinition,
                dateFormatter: formatter,
                defaultDateFormat: "Y-MM-dd",
                logger: logger
            )
            return converter.convert(rawContent: $0)
        }

        // redirects
        let redirectDefinition = ContentDefinition.Mocks.redirect()
        let rawRedirectContents = RawContent.Mocks.redirectHomeOldAboutOld()
        let redirectContents = rawRedirectContents.map {
            let converter = ContentDefinitionConverter(
                contentDefinition: redirectDefinition,
                dateFormatter: formatter,
                defaultDateFormat: "Y-MM-dd",
                logger: logger
            )
            return converter.convert(rawContent: $0)
        }

        let contents = pageContents + redirectContents

        let blockDirectives = MarkdownBlockDirective.Mocks.highlightedTexts()
        let templates: [String: String] = [
            "redirect": Templates.Mocks.redirect()
        ]

        let config = Config.defaults
        let sourceConfig = SourceConfig(
            sourceUrl: .init(fileURLWithPath: ""),
            config: config
        )

        var sourceBundle = SourceBundle(
            location: .init(filePath: ""),
            config: config,
            sourceConfig: sourceConfig,
            settings: .defaults,
            pipelines: pipelines,
            contents: contents,
            blockDirectives: blockDirectives,
            templates: templates,
            baseUrl: ""
        )

        let renderer = SourceBundleRenderer(
            sourceBundle: sourceBundle,
            generator: .v1_0_0_beta3,
            fileManager: FileManager.default,
            logger: logger
        )
        let results = try renderer.renderPipelineResults(now: now)

        #expect(results.count == 2)

        let expectation = #"""
            <!DOCTYPE html>
            <html >
                <meta charset="utf-8">
                <title>Redirecting&hellip;</title>
                <link rel="canonical" href="home">
                <script>location="home"</script>
                <meta http-equiv="refresh" content="0; url=home">
                <meta name="robots" content="noindex">
                <h1>Redirecting&hellip;</h1>
                <a href="home">Click here if you are not redirected.</a>
            </html>
            """#

        #expect(results[0].contents == expectation)
        #expect(results[0].destination.path == "home-2")
        #expect(results[0].destination.file == "index")
        #expect(results[0].destination.ext == "html")
    }
}
