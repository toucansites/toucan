//
//  SourceBundleRSSTestSuite.swift
//  Toucan
//
//  Created by Viasz-Kádi Ferenc on 2025. 02. 20..
//

import Foundation
import Testing
import ToucanModels
import ToucanContent
import ToucanTesting
import Logging
@testable import ToucanSource

@Suite
struct SourceBundleRSSTestSuite {

    @Test
    func rss() throws {
        let logger = Logger(label: "SourceBundleRSSTestSuite")
        let now = Date()
        let target = Target.default
        let config = Config.defaults
        let sourceConfig = SourceConfig(
            sourceUrl: .init(fileURLWithPath: ""),
            config: config
        )
        let formatter = target.dateFormatter(
            sourceConfig.config.dateFormats.input
        )
        let rssFormatter = target.dateFormatter("EEE, dd MMM yyyy HH:mm:ss Z")
        let nowString = rssFormatter.string(from: now)

        let pipelines = [
            Pipeline.Mocks.rss()
        ]

        let postDefinition = ContentDefinition.Mocks.post()
        let rawPostContents = RawContent.Mocks.posts(
            max: 1,
            now: now,
            formatter: formatter
        )
        let postContents = rawPostContents.map {
            let converter = ContentDefinitionConverter(
                contentDefinition: postDefinition,
                dateFormatter: formatter,
                logger: logger
            )
            return converter.convert(rawContent: $0)
        }

        // rss
        let rssDefinition = ContentDefinition.Mocks.rss()
        let rawRSSContents = RawContent.Mocks.rss()
        let rssContents = rawRSSContents.map {
            let converter = ContentDefinitionConverter(
                contentDefinition: rssDefinition,
                dateFormatter: formatter,
                logger: logger
            )
            return converter.convert(rawContent: $0)
        }

        let contents =
            postContents + rssContents

        let blockDirectives = MarkdownBlockDirective.Mocks.highlightedTexts()
        let templates: [String: String] = [
            "rss": Templates.Mocks.rss()
        ]

        let sourceBundle = SourceBundle(
            location: .init(filePath: ""),
            target: target,
            config: config,
            sourceConfig: sourceConfig,
            settings: .init(userDefined: [:]),
            pipelines: pipelines,
            contents: contents,
            blockDirectives: blockDirectives,
            templates: templates,
            baseUrl: ""
        )

        var renderer = SourceBundleRenderer(
            sourceBundle: sourceBundle,
            fileManager: FileManager.default,
            logger: logger
        )
        let results = try renderer.render(now: now)

        #expect(results.count == 1)

        let expectation = #"""
            <rss xmlns:atom="http://www.w3.org/2005/Atom" version="2.0">
            <channel>
                <title></title>
                <description></description>
                <link>http://localhost:3000</link>
                <language>en-US</language>
                <lastBuildDate>\#(nowString)</lastBuildDate>
                <pubDate>\#(nowString)</pubDate>
                <ttl>250</ttl>
                <atom:link href="http://localhost:3000/rss.xml" rel="self" type="application/rss+xml"/>

                <item>
                    <guid isPermaLink="true">http://localhost:3000/blog/posts/post-1/</guid>
                    <title><![CDATA[ Post #1 ]]></title>
                    <description><![CDATA[  ]]></description>
                    <link>http://localhost:3000/blog/posts/post-1/</link>
                    <pubDate>\#(nowString)</pubDate>
                </item>
            </channel>
            </rss>
            """#

        #expect(results[0].destination.path == "")
        #expect(results[0].destination.file == "rss")
        #expect(results[0].destination.ext == "xml")

        switch results[0].source {
        case .assetFile(_), .asset(_):
            #expect(Bool(false))
        case .content(let value):
            #expect(value == expectation)
        }
    }
}
