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
@testable import ToucanSource

@Suite
struct SourceBundleRedirectTestSuite {

    @Test
    func redirect() throws {
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
            pageDefinition.convert(
                rawContent: $0,
                definition: pageDefinition,
                using: formatter
            )
        }

        // redirects
        let redirectDefinition = ContentDefinition.Mocks.redirect()
        let rawRedirectContents = RawContent.Mocks.redirectHomeOldAboutOld()
        let redirectContents = rawRedirectContents.map {
            redirectDefinition.convert(
                rawContent: $0,
                definition: redirectDefinition,
                using: formatter
            )
        }

        let contentBundles: [ContentBundle] = [
            .init(definition: pageDefinition, contents: pageContents),
            .init(definition: redirectDefinition, contents: redirectContents),
        ]

        let sourceBundle = SourceBundle(
            location: .init(filePath: ""),
            config: .defaults,
            settings: .defaults,
            pipelines: pipelines,
            contentBundles: contentBundles
        )

        let templates: [String: String] = [
            "redirect": Templates.Mocks.redirect()
        ]

        let results = try sourceBundle
            .generatePipelineResults(templates: templates)

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
