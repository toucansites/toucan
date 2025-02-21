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
struct SourceBundleSitemapTestSuite {

    @Test
    func sitemap() throws {
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
            tagDefinition.convert(
                rawContent: $0,
                definition: tagDefinition,
                using: formatter
            )
        }

        let authorDefinition = ContentDefinition.Mocks.author()
        let rawAuthorContents = RawContent.Mocks.authors()
        let authorContents = rawAuthorContents.map {
            authorDefinition.convert(
                rawContent: $0,
                definition: authorDefinition,
                using: formatter
            )
        }

        let postDefinition = ContentDefinition.Mocks.post()
        let rawPostContents = RawContent.Mocks.posts(
            max: 2,
            now: now,
            formatter: formatter
        )
        let postContents = rawPostContents.map {
            postDefinition.convert(
                rawContent: $0,
                definition: postDefinition,
                using: formatter
            )
        }

        // sitemap
        let sitemapDefinition = ContentDefinition.Mocks.sitemap()
        let rawSitemapContents = RawContent.Mocks.sitemap()
        let sitemapContents = rawSitemapContents.map {
            sitemapDefinition.convert(
                rawContent: $0,
                definition: sitemapDefinition,
                using: formatter
            )
        }

        let contentBundles: [ContentBundle] = [
            .init(definition: tagDefinition, contents: tagContents),
            .init(definition: authorDefinition, contents: authorContents),
            .init(definition: postDefinition, contents: postContents),
            .init(definition: sitemapDefinition, contents: sitemapContents),
        ]

        let sourceBundle = SourceBundle(
            location: .init(filePath: ""),
            config: .defaults,
            settings: .defaults,
            pipelines: pipelines,
            contentBundles: contentBundles
        )

        let templates: [String: String] = [
            "sitemap": Templates.Mocks.sitemap()
        ]

        let results = try sourceBundle.generatePipelineResults(
            templates: templates
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
}
