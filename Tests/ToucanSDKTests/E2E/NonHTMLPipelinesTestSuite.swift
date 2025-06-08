//
//  NonHTMLPipelinesTestSuite.swift
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
struct NonHTMLPipelinesTestSuite {

    @Test
    func context() throws {
        let now = Date()

        try FileManagerPlayground {
            Mocks.E2E.src(
                now: now,
                debugContext: #"""
                    {{page}}
                    """#
            )
        }
        .test {
            let input = $1.appendingPathIfPresent("src")
            try Toucan(input: input.path()).generate()

            let output = $1.appendingPathIfPresent("docs")
            let contextURL = output.appendingPathIfPresent("context/index.html")
            let context = try String(contentsOf: contextURL)

            print(context.replacingOccurrences(["&quot;": "\""]))

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

            let nowString = ""
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

            //            #expect(rss == expectation)

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
            let rssXML = output.appendingPathIfPresent("rss.xml")
            let rss = try String(contentsOf: rssXML)

            let expectation = #"""
                <!DOCTYPE html>
                <html lang="en-US">
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
            let rssXML = output.appendingPathIfPresent("rss.xml")
            let rss = try String(contentsOf: rssXML)

            let nowString = ""
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
        }
    }

    @Test
    func sitemapWithPagination() throws {
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

            let nowString = ""
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
        }
    }
}
