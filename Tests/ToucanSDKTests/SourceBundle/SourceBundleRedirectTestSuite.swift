//
//  SourceBundleRedirectTestSuite.swift
//  Toucan
//
//  Created by Viasz-Kádi Ferenc on 2025. 02. 20..
//
//
//import Foundation
//import Testing
//
//
//import ToucanMarkdown
//import Logging
//@testable import ToucanSDK
//
//@Suite
//struct SourceBundleRedirectTestSuite {
//
//    @Test
//    func redirect() throws {
//        let logger = Logger(label: "SourceBundleRedirectTestSuite")
//        let target = Target.standard
//        let config = Config.defaults
//        let sourceConfig = SourceLocations(
//            sourceUrl: .init(fileURLWithPath: ""),
//            config: config
//        )
//        let formatter = target.dateFormatter(
//            sourceConfig.config.dateFormats.input
//        )
//
//        let now = Date()
//
//        let pipelines = [
//            Pipeline.Mocks.redirect()
//        ]
//
//        let pageDefinition = ContentDefinition.Mocks.page()
//        let rawPageContents = RawContent.Mocks.pages(max: 2)
//        let pageContents = rawPageContents.map {
//            let converter = ContentDefinitionConverter(
//                contentDefinition: pageDefinition,
//                dateFormatter: formatter,
//                logger: logger
//            )
//            return converter.convert(rawContent: $0)
//        }
//
//        // redirects
//        let redirectDefinition = ContentDefinition.Mocks.redirect()
//        let rawRedirectContents = RawContent.Mocks.redirectHomeOldAboutOld()
//        let redirectContents = rawRedirectContents.map {
//            let converter = ContentDefinitionConverter(
//                contentDefinition: redirectDefinition,
//                dateFormatter: formatter,
//                logger: logger
//            )
//            return converter.convert(rawContent: $0)
//        }
//
//        let contents = pageContents + redirectContents
//
//        let blockDirectives = MarkdownBlockDirective.Mocks.highlightedTexts()
//        let templates: [String: String] = [
//            "redirect": Templates.Mocks.redirect()
//        ]
//
//        let sourceBundle = BuildTargetSource(
//            location: .init(filePath: ""),
//            target: target,
//            config: config,
//            sourceConfig: sourceConfig,
//            settings: .standard,
//            pipelines: pipelines,
//            contents: contents,
//            blockDirectives: blockDirectives,
//            templates: templates,
//            baseUrl: ""
//        )
//
//        var renderer = SourceBundleRenderer(
//            sourceBundle: sourceBundle,
//            fileManager: FileManager.default,
//            logger: logger
//        )
//        let results = try renderer.render(now: now)
//
//        #expect(results.count == 2)
//
//        let expectation = #"""
//            <!DOCTYPE html>
//            <html lang="en-US">
//                <meta charset="utf-8">
//                <title>Redirecting&hellip;</title>
//                <link rel="canonical" href="home">
//                <script>location="home"</script>
//                <meta http-equiv="refresh" content="0; url=home">
//                <meta name="robots" content="noindex">
//                <h1>Redirecting&hellip;</h1>
//                <a href="home">Click here if you are not redirected.</a>
//            </html>
//            """#
//
//        switch results[0].source {
//        case .assetFile(_), .asset(_):
//            #expect(Bool(false))
//        case .content(let value):
//            #expect(value == expectation)
//        }
//        #expect(results[0].destination.path == "home-2")
//        #expect(results[0].destination.file == "index")
//        #expect(results[0].destination.ext == "html")
//    }
//}
