//
//  NonHTMLTestSuite.swift
//  Toucan
//
//  Created by Viasz-Kádi Ferenc on 2025. 02. 20..
//
//

import Foundation
import Testing
import Logging
import ToucanCore
import ToucanSource
import FileManagerKitBuilder
@testable import ToucanSDK

@Suite
struct NonHTMLTestSuite {

    @Test
    func notFound() throws {
        let now = Date()

        try FileManagerPlayground {
            Mocks.E2E.src(
                now: now
            )
        }
        .test {
            let input = $1.appendingPathIfPresent("src")
            try Toucan(input: input.path()).generate()

            let output = $1.appendingPathIfPresent("docs")
            let notFoundUrl = output.appendingPathIfPresent("404.html")
            let notFound = try String(contentsOf: notFoundUrl)

            #expect(notFound.contains("Not found page contents"))

        }
    }

    @Test
    func rss() throws {
        let now = Date()

        try FileManagerPlayground {
            Mocks.E2E.src(now: now)
        }
        .test {
            let input = $1.appendingPathIfPresent("src")
            try Toucan(input: input.path()).generate()

            let output = $1.appendingPathIfPresent("docs")
            let rssXML = output.appendingPathIfPresent("rss.xml")
            let rss = try String(contentsOf: rssXML)

            let formatter = ToucanOutputDateFormatter(
                dateConfig: Config.defaults.dataTypes.date,
                pipelineDateConfig: Mocks.Pipelines.rss().dataTypes.date
            )

            let nowString = formatter.format(now).formats["rss"] ?? ""
            let post1date =
                formatter.format(now.addingTimeInterval(-86_400)).formats["rss"]
                ?? ""
            let post2date =
                formatter.format(now.addingTimeInterval(-86_400 * 2))
                .formats["rss"] ?? ""
            let post3date =
                formatter.format(now.addingTimeInterval(-86_400 * 3))
                .formats["rss"] ?? ""

            print(post1date)

            let expectation = #"""
                <rss xmlns:atom="http://www.w3.org/2005/Atom" version="2.0">
                <channel>
                    <title>Test site name</title>
                    <description>Test site description</description>
                    <link>http://localhost:3000</link>
                    <language>en-US</language>
                    <lastBuildDate>\#(nowString)</lastBuildDate>
                    <pubDate>\#(nowString)</pubDate>
                    <ttl>250</ttl>
                    <atom:link href="http://localhost:3000/rss.xml" rel="self" type="application/rss+xml"/>

                    <item>
                        <guid isPermaLink="true">http://localhost:3000/blog/posts/post-1/</guid>
                        <title><![CDATA[ Post #1 ]]></title>
                        <description><![CDATA[ Post #1 description ]]></description>
                        <link>http://localhost:3000/blog/posts/post-1/</link>
                        <pubDate>\#(post1date)</pubDate>
                    </item>
                    <item>
                        <guid isPermaLink="true">http://localhost:3000/blog/posts/post-2/</guid>
                        <title><![CDATA[ Post #2 ]]></title>
                        <description><![CDATA[ Post #2 description ]]></description>
                        <link>http://localhost:3000/blog/posts/post-2/</link>
                        <pubDate>\#(post2date)</pubDate>
                    </item>
                    <item>
                        <guid isPermaLink="true">http://localhost:3000/blog/posts/post-3/</guid>
                        <title><![CDATA[ Post #3 ]]></title>
                        <description><![CDATA[ Post #3 description ]]></description>
                        <link>http://localhost:3000/blog/posts/post-3/</link>
                        <pubDate>\#(post3date)</pubDate>
                    </item>

                </channel>
                </rss>
                """#

            #expect(
                rss.trimmingCharacters(in: .whitespacesAndNewlines)
                    == expectation.trimmingCharacters(
                        in: .whitespacesAndNewlines
                    )
            )
        }
    }

    @Test
    func sitemap() throws {
        let now = Date()

        try FileManagerPlayground {
            Mocks.E2E.src(now: now)
        }
        .test {
            let input = $1.appendingPathIfPresent("src")
            try Toucan(input: input.path()).generate()

            let output = $1.appendingPathIfPresent("docs")
            let sitemapXML = output.appendingPathIfPresent("sitemap.xml")
            let sitemap = try String(contentsOf: sitemapXML)

            let formatter = ToucanOutputDateFormatter(
                dateConfig: Config.defaults.dataTypes.date,
                pipelineDateConfig: Mocks.Pipelines.sitemap().dataTypes.date
            )

            let nowString = formatter.format(now).formats["sitemap"] ?? ""

            let expectation = #"""
                <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
                    <url>

                        <loc>http://localhost:3000/</loc>
                        <lastmod>\#(nowString)</lastmod>
                        <loc>http://localhost:3000/about/</loc>
                        <lastmod>\#(nowString)</lastmod>
                        <loc>http://localhost:3000/blog/posts/pages/1/</loc>
                        <lastmod>\#(nowString)</lastmod>
                        <loc>http://localhost:3000/blog/posts/pages/2/</loc>
                        <lastmod>\#(nowString)</lastmod>
                        <loc>http://localhost:3000/context/</loc>
                        <lastmod>\#(nowString)</lastmod>
                        <loc>http://localhost:3000/pages/page-1/</loc>
                        <lastmod>\#(nowString)</lastmod>
                        <loc>http://localhost:3000/pages/page-2/</loc>
                        <lastmod>\#(nowString)</lastmod>
                        <loc>http://localhost:3000/pages/page-3/</loc>
                        <lastmod>\#(nowString)</lastmod>

                        <loc>http://localhost:3000/blog/posts/post-1/</loc>
                        <lastmod>\#(nowString)</lastmod>
                        <loc>http://localhost:3000/blog/posts/post-2/</loc>
                        <lastmod>\#(nowString)</lastmod>
                        <loc>http://localhost:3000/blog/posts/post-3/</loc>
                        <lastmod>\#(nowString)</lastmod>

                        <loc>http://localhost:3000/blog/authors/author-1/</loc>
                        <lastmod>\#(nowString)</lastmod>
                        <loc>http://localhost:3000/blog/authors/author-2/</loc>
                        <lastmod>\#(nowString)</lastmod>
                        <loc>http://localhost:3000/blog/authors/author-3/</loc>
                        <lastmod>\#(nowString)</lastmod>

                        <loc>http://localhost:3000/blog/tags/tag-1/</loc>
                        <lastmod>\#(nowString)</lastmod>
                        <loc>http://localhost:3000/blog/tags/tag-2/</loc>
                        <lastmod>\#(nowString)</lastmod>
                        <loc>http://localhost:3000/blog/tags/tag-3/</loc>
                        <lastmod>\#(nowString)</lastmod>
                    


                    </url>
                </urlset>
                """#

            #expect(
                sitemap.trimmingCharacters(in: .whitespacesAndNewlines)
                    == expectation.trimmingCharacters(
                        in: .whitespacesAndNewlines
                    )
            )
        }
    }

    @Test
    func redirect() throws {
        let now = Date()

        try FileManagerPlayground {
            Mocks.E2E.src(now: now)
        }
        .test {
            let input = $1.appendingPathIfPresent("src")
            try Toucan(input: input.path()).generate()

            let output = $1.appendingPathIfPresent("docs")

            let redirect1URL = output.appendingPathIfPresent(
                "redirects/home-old/index.html"
            )
            let redirect1 = try String(contentsOf: redirect1URL)
            let expectation1 = #"""
                <!DOCTYPE html>
                <html lang="en-US">
                  <meta charset="utf-8">
                  <title>Redirecting&hellip;</title>
                  <link rel="canonical" href="http://localhost:3000/">
                  <script>location="http://localhost:3000/"</script>
                  <meta http-equiv="refresh" content="0; url=http://localhost:3000/">
                  <meta name="robots" content="noindex">
                  <h1>Redirecting&hellip;</h1>
                  <a href="http://localhost:3000/">Click here if you are not redirected.</a>
                </html>
                """#

            #expect(
                redirect1.trimmingCharacters(in: .whitespacesAndNewlines)
                    == expectation1.trimmingCharacters(
                        in: .whitespacesAndNewlines
                    )
            )

            let redirect2URL = output.appendingPathIfPresent(
                "redirects/about-old/index.html"
            )
            let redirect2 = try String(contentsOf: redirect2URL)
            let expectation2 = #"""
                <!DOCTYPE html>
                <html lang="en-US">
                  <meta charset="utf-8">
                  <title>Redirecting&hellip;</title>
                  <link rel="canonical" href="http://localhost:3000/about">
                  <script>location="http://localhost:3000/about"</script>
                  <meta http-equiv="refresh" content="0; url=http://localhost:3000/about">
                  <meta name="robots" content="noindex">
                  <h1>Redirecting&hellip;</h1>
                  <a href="http://localhost:3000/about">Click here if you are not redirected.</a>
                </html>
                """#

            #expect(
                redirect2.trimmingCharacters(in: .whitespacesAndNewlines)
                    == expectation2.trimmingCharacters(
                        in: .whitespacesAndNewlines
                    )
            )
        }
    }
}
