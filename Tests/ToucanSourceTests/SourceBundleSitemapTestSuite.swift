//
//  SourceBundleSitemapTestSuite.swift
//  toucan
//
//  Created by Lengyel Gábor on 2025. 03. 26..
//

import Foundation
import Testing
import ToucanModels
import ToucanContent
import ToucanTesting
import Logging
@testable import ToucanSource

@Suite
struct SourceBundleSitemapTestSuite {

    @Test
    func sitemap() throws {
        let logger = Logger(label: "SourceBundleSitemapTestSuite")
        let now = Date()
        let formatter = DateFormatter()
        formatter.locale = .init(identifier: "en_US")
        formatter.timeZone = .init(secondsFromGMT: 0)

        formatter.dateFormat = "Y-MM-dd"
        let nowString = formatter.string(from: now)

        let pipelines = [
            Pipeline.Mocks.sitemap()
        ]

        let tagDefinition = ContentDefinition.Mocks.tag()
        let rawTagContents = RawContent.Mocks.tags()
        let tagContents = rawTagContents.map {
            let converter = ContentDefinitionConverter(
                contentDefinition: tagDefinition,
                dateFormatter: formatter,
                defaultDateFormat: "Y-MM-dd",
                logger: logger
            )
            return converter.convert(rawContent: $0)
        }

        let authorDefinition = ContentDefinition.Mocks.author()
        let rawAuthorContents = RawContent.Mocks.authors()
        let authorContents = rawAuthorContents.map {
            let converter = ContentDefinitionConverter(
                contentDefinition: authorDefinition,
                dateFormatter: formatter,
                defaultDateFormat: "Y-MM-dd",
                logger: logger
            )
            return converter.convert(rawContent: $0)
        }

        let postDefinition = ContentDefinition.Mocks.post()
        let rawPostContents = RawContent.Mocks.posts(
            max: 2,
            now: now,
            formatter: formatter
        )
        let postContents = rawPostContents.map {
            let converter = ContentDefinitionConverter(
                contentDefinition: postDefinition,
                dateFormatter: formatter,
                defaultDateFormat: "Y-MM-dd",
                logger: logger
            )
            return converter.convert(rawContent: $0)
        }

        // sitemap
        let sitemapDefinition = ContentDefinition.Mocks.sitemap()
        let rawSitemapContents = RawContent.Mocks.sitemap()
        let sitemapContents = rawSitemapContents.map {
            let converter = ContentDefinitionConverter(
                contentDefinition: sitemapDefinition,
                dateFormatter: formatter,
                defaultDateFormat: "Y-MM-dd",
                logger: logger
            )
            return converter.convert(rawContent: $0)
        }

        let contents =
            tagContents + authorContents + postContents + sitemapContents

        let templates: [String: String] = [
            "sitemap": Templates.Mocks.sitemap()
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
            blockDirectives: [],
            templates: templates,
            baseUrl: ""
        )

        let results = try sourceBundle.generatePipelineResults(
            now: now,
            generator: .v1_0_0_beta3
        )

        #expect(results.count == 1)

        let expectation = #"""
            <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
                <url>
                    <loc>http://localhost:3000/blog/tags/tag-1/</loc>
                    <lastmod>\#(nowString)</lastmod>
                    <loc>http://localhost:3000/blog/tags/tag-2/</loc>
                    <lastmod>\#(nowString)</lastmod>

                    <loc>http://localhost:3000/blog/authors/author-1/</loc>
                    <lastmod>\#(nowString)</lastmod>
                    <loc>http://localhost:3000/blog/authors/author-2/</loc>
                    <lastmod>\#(nowString)</lastmod>

                    <loc>http://localhost:3000/blog/posts/post-1/</loc>
                    <lastmod>\#(nowString)</lastmod>
                    <loc>http://localhost:3000/blog/posts/post-2/</loc>
                    <lastmod>\#(nowString)</lastmod>
                </url>
            </urlset>
            """#

        #expect(results[0].contents == expectation)
        #expect(results[0].destination.path == "")
        #expect(results[0].destination.file == "sitemap")
        #expect(results[0].destination.ext == "xml")
    }
    
    @Test
    func sitemapWithPagination() throws {
        let logger = Logger(label: "SourceBundleSitemapTestSuite")
        let now = Date()
        let formatter = DateFormatter()
        formatter.locale = .init(identifier: "en_US")
        formatter.timeZone = .init(secondsFromGMT: 0)

        formatter.dateFormat = "Y-MM-dd"
        let nowString = formatter.string(from: now)

        let pipelines = [
            Pipeline.Mocks.html(),
            Pipeline.Mocks.sitemap()
        ]

        let tagDefinition = ContentDefinition.Mocks.tag()
        let rawTagContents = RawContent.Mocks.tags()
        let tagContents = rawTagContents.map {
            let converter = ContentDefinitionConverter(
                contentDefinition: tagDefinition,
                dateFormatter: formatter,
                defaultDateFormat: "Y-MM-dd",
                logger: logger
            )
            return converter.convert(rawContent: $0)
        }

        let authorDefinition = ContentDefinition.Mocks.author()
        let rawAuthorContents = RawContent.Mocks.authors()
        let authorContents = rawAuthorContents.map {
            let converter = ContentDefinitionConverter(
                contentDefinition: authorDefinition,
                dateFormatter: formatter,
                defaultDateFormat: "Y-MM-dd",
                logger: logger
            )
            return converter.convert(rawContent: $0)
        }

        let postDefinition = ContentDefinition.Mocks.post()
        let rawPostContents = RawContent.Mocks.posts(
            max: 2,
            now: now,
            formatter: formatter
        )
        let postContents = rawPostContents.map {
            let converter = ContentDefinitionConverter(
                contentDefinition: postDefinition,
                dateFormatter: formatter,
                defaultDateFormat: "Y-MM-dd",
                logger: logger
            )
            return converter.convert(rawContent: $0)
        }

        // sitemap
        let sitemapDefinition = ContentDefinition.Mocks.sitemap()
        let rawSitemapContents = RawContent.Mocks.sitemap()
        let sitemapContents = rawSitemapContents.map {
            let converter = ContentDefinitionConverter(
                contentDefinition: sitemapDefinition,
                dateFormatter: formatter,
                defaultDateFormat: "Y-MM-dd",
                logger: logger
            )
            return converter.convert(rawContent: $0)
        }

        var contents = tagContents + authorContents + postContents + sitemapContents
        contents.append(Content.Mocks.pagination(now: now))

        let templates: [String: String] = [
            "default": Templates.Mocks.default(),
            "post.default": Templates.Mocks.post(),
            "sitemap": Templates.Mocks.sitemap()
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
            blockDirectives: [],
            templates: templates,
            baseUrl: ""
        )

        let results = try sourceBundle.generatePipelineResults(
            now: now,
            generator: .v1_0_0_beta3
        )
        
        #expect(results.first(where: { $0.destination.file == "sitemap" }) != nil)
        
        if let sitemap = results.first(where: { $0.destination.file == "sitemap" }) {
            
            let expectation = #"""
                <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
                    <url>
                        <loc>http://localhost:3000/posts/page/1/</loc>
                        <lastmod>\#(nowString)</lastmod>

                        <loc>http://localhost:3000/blog/tags/tag-1/</loc>
                        <lastmod>\#(nowString)</lastmod>
                        <loc>http://localhost:3000/blog/tags/tag-2/</loc>
                        <lastmod>\#(nowString)</lastmod>

                        <loc>http://localhost:3000/blog/authors/author-1/</loc>
                        <lastmod>\#(nowString)</lastmod>
                        <loc>http://localhost:3000/blog/authors/author-2/</loc>
                        <lastmod>\#(nowString)</lastmod>

                        <loc>http://localhost:3000/blog/posts/post-1/</loc>
                        <lastmod>\#(nowString)</lastmod>
                        <loc>http://localhost:3000/blog/posts/post-2/</loc>
                        <lastmod>\#(nowString)</lastmod>
                    </url>
                </urlset>
                """#

            #expect(sitemap.contents == expectation)
            #expect(sitemap.destination.path == "")
            #expect(sitemap.destination.file == "sitemap")
            #expect(sitemap.destination.ext == "xml")
        }

    }
    
}
