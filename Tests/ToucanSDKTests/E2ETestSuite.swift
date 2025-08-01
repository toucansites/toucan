//
//  E2ETestSuite.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 06. 11..
//

import FileManagerKitBuilder
import Foundation
import Logging
import Testing
import ToucanCore
@testable import ToucanSDK
import ToucanSource

@Suite
struct E2ETestSuite {

    @Test
    func notFound() throws {
        let now = Date()

        try FileManagerPlayground {
            Mocks.E2E.src(
                now: now
            )
        }
        .test {
            let workDir = $1.appendingPathIfPresent("src")
            let toucan = Toucan()

            try toucan.generate(
                workDir: workDir.path(),
                now: now
            )

            let distURL = workDir.appendingPathIfPresent("dist")
            let notFoundURL = distURL.appendingPathIfPresent("404.html")
            let notFound = try String(contentsOf: notFoundURL, encoding: .utf8)

            #expect(notFound.contains("Not found page contents"))
        }
    }

    // MARK: - non-html files

    @Test
    func rss() throws {
        let now = Date()

        try FileManagerPlayground {
            Mocks.E2E.src(now: now)
        }
        .test {
            let workDir = $1.appendingPathIfPresent("src")
            let toucan = Toucan()
            try toucan.generate(
                workDir: workDir.path(),
                now: now
            )

            let distURL = workDir.appendingPathIfPresent("dist")
            let rssXML = distURL.appendingPathIfPresent("rss.xml")
            let rss = try String(contentsOf: rssXML, encoding: .utf8)

            let formatter = ToucanOutputDateFormatter(
                dateConfig: Config.defaults.dataTypes.date,
                pipelineDateConfig: Mocks.Pipelines.rss().dataTypes.date
            )

            let nowString = formatter.format(now).formats["rss"] ?? ""
            let post1date =
                formatter.format(now.addingTimeInterval(-86400)).formats["rss"]
                ?? ""
            let post2date =
                formatter.format(now.addingTimeInterval(-86400 * 2))
                .formats["rss"] ?? ""
            let post3date =
                formatter.format(now.addingTimeInterval(-86400 * 3))
                .formats["rss"] ?? ""

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

            let workDir = $1.appendingPathIfPresent("src")

            let toucan = Toucan()
            try toucan.generate(
                workDir: workDir.path(),
                now: now
            )

            let distURL = workDir.appendingPathIfPresent("dist")
            let sitemapXML = distURL.appendingPathIfPresent("sitemap.xml")
            let sitemap = try String(contentsOf: sitemapXML, encoding: .utf8)

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
            let workDir = $1.appendingPathIfPresent("src")
            let toucan = Toucan()
            try toucan.generate(
                workDir: workDir.path(),
                now: now
            )

            let distURL = workDir.appendingPathIfPresent("dist")

            let redirect1URL = distURL.appendingPathIfPresent(
                "redirects/home-old/index.html"
            )
            let redirect1 = try String(
                contentsOf: redirect1URL,
                encoding: .utf8
            )
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

            let redirect2URL = distURL.appendingPathIfPresent(
                "redirects/about-old/index.html"
            )
            let redirect2 = try String(
                contentsOf: redirect2URL,
                encoding: .utf8
            )
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

    // MARK: - other tests

    @Test
    func customContextViewForAllPipeline() throws {
        let now = Date()

        try FileManagerPlayground {
            Mocks.E2E.src(
                now: now,
                debugContext: #"""
                    {{page.description}}
                    """#
            )
        }
        .test {
            let workDir = $1.appendingPathIfPresent("src")
            let toucan = Toucan()
            try toucan.generate(
                workDir: workDir.path(),
                now: now
            )

            let distURL = workDir.appendingPathIfPresent("dist")
            let htmlURL = distURL.appendingPathIfPresent("context/index.html")
            let html = try String(contentsOf: htmlURL, encoding: .utf8)
            let exp = "Context page description"
            #expect(html.trimmingCharacters(in: .whitespacesAndNewlines) == exp)
        }
    }

    // MARK: - assets

    private func mockSiteYAMLFile() -> YAMLFile<Settings> {
        .init(
            name: "site",
            contents: Settings(
                [
                    "name": "Test site name",
                    "description": "Test site description",
                    "language": "en-US",
                ]
            )
        )
    }

    private func mockTestTypes() -> Directory {
        Directory(name: "types") {
            YAMLFile(
                name: "test",
                contents: ContentType(
                    id: "test",
                    default: true
                )
            )
        }
    }

    @Test
    func loadOneSVGFile() async throws {
        let now = Date()

        try FileManagerPlayground {
            Directory(name: "src") {
                mockSiteYAMLFile()
                Directory(name: "pipelines") {
                    YAMLFile(
                        name: "test",
                        contents: Pipeline(
                            id: "test",
                            assets: .init(
                                properties: [
                                    .init(
                                        action: .load,
                                        property: "icon",
                                        resolvePath: false,
                                        input: .init(
                                            path: nil,
                                            name: "icon",
                                            ext: "svg"
                                        )
                                    )
                                ]
                            ),
                            engine: .init(
                                id: "json",
                                options: [
                                    "keyPath": "page"
                                ]
                            ),
                            output: .init(
                                path: "",
                                file: "context",
                                ext: "json"
                            )
                        )
                    )
                }
                mockTestTypes()
                Directory(name: "contents") {
                    RawContentBundle(
                        name: "test",
                        rawContent: .init(
                            origin: .init(
                                path: .init("test"),
                                slug: "test"
                            ),
                            markdown: .init(
                                frontMatter: [
                                    "type": "test"
                                ]
                            ),
                            lastModificationDate: now.timeIntervalSince1970,
                            assetsPath: "assets",
                            assets: [
                                "icon.svg",
                                "foo.svg",
                                "bar.svg",
                            ]
                        )
                    )
                }
            }
        }
        .test {
            let workDir = $1.appendingPathIfPresent("src")
            let toucan = Toucan()
            try toucan.generate(
                workDir: workDir.path(),
                now: now
            )

            let distURL = workDir.appendingPathIfPresent("dist")
            let contextURL = distURL.appendingPathIfPresent("context.json")
            //            let context = try String(contentsOf: contextURL, encoding: .utf8)
            let data = try Data(contentsOf: contextURL)

            let decoder = JSONDecoder()

            struct Exp: Decodable {
                let icon: String
            }

            let exp = try decoder.decode(Exp.self, from: data)
            #expect(exp.icon == "icon.svg")
        }
    }

    @Test
    func loadMultipleSVGFiles() async throws {
        let now = Date()

        try FileManagerPlayground {
            Directory(name: "src") {
                mockSiteYAMLFile()
                Directory(name: "pipelines") {
                    YAMLFile(
                        name: "test",
                        contents: Pipeline(
                            id: "test",
                            assets: .init(
                                properties: [
                                    .init(
                                        action: .load,
                                        property: "icons",
                                        resolvePath: false,
                                        input: .init(
                                            path: nil,
                                            name: "*",
                                            ext: "svg"
                                        )
                                    )
                                ]
                            ),
                            transformers: [:],
                            engine: .init(
                                id: "json",
                                options: [
                                    "keyPath": "page"
                                ]
                            ),
                            output: .init(
                                path: "",
                                file: "context",
                                ext: "json"
                            )
                        )
                    )
                }
                mockTestTypes()
                Directory(name: "contents") {
                    RawContentBundle(
                        name: "test",
                        rawContent: .init(
                            origin: .init(
                                path: .init("test"),
                                slug: "test"
                            ),
                            markdown: .init(
                                frontMatter: [
                                    "type": "test"
                                ]
                            ),
                            lastModificationDate: now.timeIntervalSince1970,
                            assetsPath: "assets",
                            assets: [
                                "cover.jpg",
                                "foo.svg",
                                "bar.svg",
                            ]
                        )
                    )
                }
            }
        }
        .test {
            let workDir = $1.appendingPathIfPresent("src")
            let toucan = Toucan()
            try toucan.generate(
                workDir: workDir.path(),
                now: now
            )

            let distURL = workDir.appendingPathIfPresent("dist")
            let contextURL = distURL.appendingPathIfPresent("context.json")
            //            let context = try String(contentsOf: contextURL, encoding: .utf8)
            let data = try Data(contentsOf: contextURL)

            let decoder = JSONDecoder()

            struct Exp: Decodable {
                let icons: [String: String]
            }

            let exp = try decoder.decode(Exp.self, from: data)

            #expect(exp.icons.keys.sorted() == ["foo", "bar"].sorted())
            #expect(
                exp.icons.values.sorted()
                    == [
                        "foo.svg",
                        "bar.svg",
                    ]
                    .sorted()
            )
        }
    }

    @Test
    func parseOneDataFile() async throws {
        let now = Date()

        try FileManagerPlayground {
            Directory(name: "src") {
                mockSiteYAMLFile()
                Directory(name: "pipelines") {
                    YAMLFile(
                        name: "test",
                        contents: Pipeline(
                            id: "test",
                            assets: .init(
                                properties: [
                                    .init(
                                        action: .parse,
                                        property: "data",
                                        resolvePath: false,
                                        input: .init(
                                            path: nil,
                                            name: "data",
                                            ext: "yaml"
                                        )
                                    )
                                ]
                            ),
                            engine: .init(
                                id: "json",
                                options: [
                                    "keyPath": "page"
                                ]
                            ),
                            output: .init(
                                path: "",
                                file: "context",
                                ext: "json"
                            )
                        )
                    )
                }
                mockTestTypes()
                Directory(name: "contents") {
                    Directory(name: "test") {
                        Directory(name: "assets") {
                            File(
                                name: "data.yaml",
                                string: """
                                    foo: value1
                                    bar: value2
                                    """
                            )
                        }
                        MarkdownFile(
                            name: "index",
                            markdown: .init(
                                frontMatter: [
                                    "type": "test"
                                ]
                            )
                        )
                    }
                }
            }
        }
        .test {
            let workDir = $1.appendingPathIfPresent("src")
            let toucan = Toucan()
            try toucan.generate(
                workDir: workDir.path(),
                now: now
            )

            let distURL = workDir.appendingPathIfPresent("dist")
            let contextURL = distURL.appendingPathIfPresent("context.json")
            //            let context = try String(contentsOf: contextURL, encoding: .utf8)
            let data = try Data(contentsOf: contextURL)

            let decoder = JSONDecoder()

            struct Exp: Decodable {
                let data: [String: String]
            }

            let exp = try decoder.decode(Exp.self, from: data)
            #expect(exp.data["foo"] == "value1")
            #expect(exp.data["bar"] == "value2")
        }
    }

    @Test
    func parseMultipleDataFile() async throws {
        let now = Date()

        try FileManagerPlayground {
            Directory(name: "src") {
                mockSiteYAMLFile()
                Directory(name: "pipelines") {
                    YAMLFile(
                        name: "test",
                        contents: Pipeline(
                            id: "test",
                            assets: .init(
                                properties: [
                                    .init(
                                        action: .parse,
                                        property: "data",
                                        resolvePath: false,
                                        input: .init(
                                            path: nil,
                                            name: "*",
                                            ext: "yaml"
                                        )
                                    )
                                ]
                            ),
                            engine: .init(
                                id: "json",
                                options: [
                                    "keyPath": "page"
                                ]
                            ),
                            output: .init(
                                path: "",
                                file: "context",
                                ext: "json"
                            )
                        )
                    )
                }
                mockTestTypes()
                Directory(name: "contents") {
                    Directory(name: "test") {
                        Directory(name: "assets") {
                            File(
                                name: "foo.yaml",
                                string: """
                                    foo: value1
                                    """
                            )
                            File(
                                name: "bar.yaml",
                                string: """
                                    bar: value2
                                    """
                            )
                        }
                        MarkdownFile(
                            name: "index",
                            markdown: .init(
                                frontMatter: [
                                    "type": "test"
                                ]
                            )
                        )
                    }
                }
            }
        }
        .test {
            let workDir = $1.appendingPathIfPresent("src")
            let toucan = Toucan()
            try toucan.generate(
                workDir: workDir.path(),
                now: now
            )

            let distURL = workDir.appendingPathIfPresent("dist")
            let contextURL = distURL.appendingPathIfPresent("context.json")
            //            let context = try String(contentsOf: contextURL, encoding: .utf8)
            let data = try Data(contentsOf: contextURL)

            let decoder = JSONDecoder()

            struct Exp: Decodable {
                let data: [String: [String: String]]
            }

            let exp = try decoder.decode(Exp.self, from: data)
            #expect(exp.data["foo"]?["foo"] == "value1")
            #expect(exp.data["bar"]?["bar"] == "value2")
        }
    }

    // MARK: - asset behaviors

    @Test
    func minifyCSSAsset() async throws {
        let now = Date()

        try FileManagerPlayground {
            Directory(name: "src") {
                mockSiteYAMLFile()
                Directory(name: "pipelines") {
                    YAMLFile(
                        name: "test",
                        contents: Pipeline(
                            id: "test",
                            assets: .init(
                                behaviors: [
                                    .init(
                                        id: "minify-css",
                                        input: .init(
                                            name: "style",
                                            ext: "css"
                                        ),
                                        output: .init(
                                            name: "style.min",
                                            ext: "css"
                                        )
                                    )
                                ]
                            ),
                            engine: .init(
                                id: "json",
                                options: [
                                    "keyPath": "page"
                                ]
                            ),
                            output: .init(
                                path: "",
                                file: "context",
                                ext: "json"
                            )
                        )
                    )
                }
                mockTestTypes()
                Directory(name: "contents") {
                    Directory(name: "test") {
                        Directory(name: "assets") {
                            File(
                                name: "style.css",
                                string: """
                                    html {
                                        margin: 0;
                                        padding: 0;
                                    }
                                    body {
                                        background: red;
                                    }
                                    """
                            )
                        }
                        MarkdownFile(
                            name: "index",
                            markdown: .init(
                                frontMatter: [
                                    "type": "test"
                                ]
                            )
                        )
                    }
                }
            }
        }
        .test {
            let workDir = $1.appendingPathIfPresent("src")
            let toucan = Toucan()
            try toucan.generate(
                workDir: workDir.path(),
                now: now
            )

            let distURL = workDir.appendingPathIfPresent("dist")
            let cssURL = distURL.appendingPathIfPresent(
                "assets/test/style.min.css"
            )

            let css = try String(contentsOf: cssURL, encoding: .utf8)

            #expect(
                css.contains(
                    "html{margin:0;padding:0}body{background:red}"
                )
            )
        }
    }

    @Test
    func sASSAsset() async throws {
        let now = Date()

        try FileManagerPlayground {
            Directory(name: "src") {
                mockSiteYAMLFile()
                Directory(name: "pipelines") {
                    YAMLFile(
                        name: "test",
                        contents: Pipeline(
                            id: "test",
                            assets: .init(
                                behaviors: [
                                    .init(
                                        id: "compile-sass",
                                        input: .init(
                                            name: "style",
                                            ext: "sass"
                                        ),
                                        output: .init(
                                            name: "style",
                                            ext: "css"
                                        )
                                    )
                                ]
                            ),
                            engine: .init(
                                id: "json",
                                options: [
                                    "keyPath": "page"
                                ]
                            ),
                            output: .init(
                                path: "",
                                file: "context",
                                ext: "json"
                            )
                        )
                    )
                }
                mockTestTypes()
                Directory(name: "contents") {
                    Directory(name: "test") {
                        Directory(name: "assets") {
                            File(
                                name: "style.sass",
                                string: """
                                    $font-stack: Helvetica, sans-serif
                                    $primary-color: #333

                                    body
                                      font: 100% $font-stack
                                      color: $primary-color
                                    """
                            )
                        }
                        MarkdownFile(
                            name: "index",
                            markdown: .init(
                                frontMatter: [
                                    "type": "test"
                                ]
                            )
                        )
                    }
                }
            }
        }
        .test {
            let workDir = $1.appendingPathIfPresent("src")
            let toucan = Toucan()
            try toucan.generate(
                workDir: workDir.path(),
                now: now
            )

            let distURL = workDir.appendingPathIfPresent("dist")
            let cssURL = distURL.appendingPathIfPresent(
                "assets/test/style.css"
            )

            let css = try String(contentsOf: cssURL, encoding: .utf8)

            #expect(
                css.contains(
                    """
                    body {
                      font: 100% Helvetica, sans-serif;
                      color: #333;
                    }
                    """
                )
            )
        }
    }

    @Test
    func sCSSModuleLoader() async throws {
        let now = Date()

        try FileManagerPlayground {
            Directory(name: "src") {
                mockSiteYAMLFile()
                Directory(name: "pipelines") {
                    YAMLFile(
                        name: "test",
                        contents: Pipeline(
                            id: "test",
                            assets: .init(
                                behaviors: [
                                    .init(
                                        id: "compile-sass",
                                        input: .init(
                                            name: "style",
                                            ext: "scss"
                                        ),
                                        output: .init(
                                            name: "style",
                                            ext: "css"
                                        )
                                    )
                                ]
                            ),
                            engine: .init(
                                id: "json",
                                options: [
                                    "keyPath": "page"
                                ]
                            ),
                            output: .init(
                                path: "",
                                file: "context",
                                ext: "json"
                            )
                        )
                    )
                }
                mockTestTypes()
                Directory(name: "contents") {
                    Directory(name: "test") {
                        Directory(name: "assets") {
                            File(
                                name: "_colors.scss",
                                string: """
                                    $primary: blue;
                                    """
                            )
                            File(
                                name: "style.scss",
                                string: """
                                    @use "colors";

                                    body {
                                      color: colors.$primary;
                                    }
                                    """
                            )
                        }
                        MarkdownFile(
                            name: "index",
                            markdown: .init(
                                frontMatter: [
                                    "type": "test"
                                ]
                            )
                        )
                    }
                }
            }
        }
        .test {
            let workDir = $1.appendingPathIfPresent("src")
            let toucan = Toucan()
            try toucan.generate(
                workDir: workDir.path(),
                now: now
            )

            let distURL = workDir.appendingPathIfPresent("dist")
            let cssURL = distURL.appendingPathIfPresent(
                "assets/test/style.css"
            )

            let css = try String(contentsOf: cssURL, encoding: .utf8)

            #expect(
                css.contains(
                    """
                    body {
                      color: blue;
                    }
                    """
                )
            )
        }
    }

    // MARK: - custom view

    @Test
    func customView() async throws {
        let now = Date()

        try FileManagerPlayground {
            Directory(name: "src") {
                mockSiteYAMLFile()
                Directory(name: "pipelines") {
                    YAMLFile(
                        name: "html",
                        contents: Pipeline(
                            id: "html",
                            engine: .init(
                                id: "mustache",
                                options: [
                                    "contentTypes": [
                                        "test": [
                                            "view": "foo"
                                        ]
                                    ]
                                ]
                            ),
                            output: .init(
                                path: "{{slug}}",
                                file: "index",
                                ext: "html"
                            )
                        )
                    )
                }
                mockTestTypes()
                Directory(name: "contents") {
                    Directory(name: "test") {
                        File(
                            name: "index.yaml",
                            string: """
                                views:
                                    html: bar
                                """
                        )
                    }
                }
                Directory(name: "templates") {
                    Directory(name: "default") {
                        YAMLFile(
                            name: "template",
                            contents: Mocks.Templates.metadata()
                        )
                        Directory(name: "views") {
                            MustacheFile(
                                name: "foo",
                                contents: """
                                    foo
                                    """
                            )
                            MustacheFile(
                                name: "bar",
                                contents: """
                                    bar
                                    """
                            )
                        }
                    }
                }
            }
        }
        .test {
            let workDir = $1.appendingPathIfPresent("src")
            let toucan = Toucan()
            try toucan.generate(
                workDir: workDir.path(),
                now: now
            )

            let distURL = workDir.appendingPathIfPresent("dist")

            let fileURL = distURL.appendingPathIfPresent("test/index.html")
            let html = try String(contentsOf: fileURL, encoding: .utf8)

            #expect(html.contains("bar"))
        }
    }

    // MARK: - transformers

    @Test
    func transformerExecution() async throws {
        let now = Date()
        let fileManager = FileManager.default
        let rootURL = FileManager.default.temporaryDirectory
        let rootName = "FileManagerPlayground_\(UUID().uuidString)"

        try FileManagerPlayground(
            rootUrl: rootURL,
            rootName: rootName,
            fileManager: fileManager
        ) {
            Directory(name: "src") {
                mockSiteYAMLFile()
                Directory(name: "pipelines") {
                    YAMLFile(
                        name: "test",
                        contents: Pipeline(
                            id: "test",
                            transformers: [
                                "test": .init(
                                    run: [
                                        .init(
                                            path:
                                                "\(rootURL.path())/\(rootName)/src/transformers",
                                            name: "replace"
                                        )
                                    ],
                                    isMarkdownResult: false
                                )
                            ],
                            engine: .init(
                                id: "mustache",
                                options: [
                                    "contentTypes": [
                                        "test": [
                                            "view": "test"
                                        ]
                                    ]
                                ]
                            ),
                            output: .init(
                                path: "{{slug}}",
                                file: "index",
                                ext: "html"
                            )
                        )
                    )
                }
                mockTestTypes()
                Directory(name: "contents") {
                    Directory(name: "test") {
                        File(
                            name: "index.yaml",
                            string: """
                                type: test
                                description: Desc1
                                label: label1
                                """
                        )
                        File(
                            name: "index.md",
                            string: """
                                ---
                                title: "First beta release"
                                ---
                                Character to replace => :
                                """
                        )
                    }
                }
                Directory(name: "transformers") {
                    File(
                        name: "replace",
                        attributes: [.posixPermissions: 0o777],
                        string: """
                            #!/bin/bash
                            # Replaces all colons `:` with dashes `-` in the given file.
                            # Usage: replace-char --file <path>
                            UNKNOWN_ARGS=()
                            while [[ $# -gt 0 ]]; do
                                case $1 in
                                    --file)
                                        TOUCAN_FILE="$2"
                                        shift
                                        shift
                                        ;;
                                    -*|--*)
                                        UNKNOWN_ARGS+=("$1" "$2")
                                        shift
                                        shift
                                        ;;
                                    *)
                                        shift
                                        ;;
                                esac
                            done
                            if [[ -z "${TOUCAN_FILE}" ]]; then
                                echo "❌ No file specified with --file."
                                exit 1
                            fi
                            echo "📄 Processing file: ${TOUCAN_FILE}"
                            if [[ ${#UNKNOWN_ARGS[@]} -gt 0 ]]; then
                                echo "ℹ️ Ignored unknown options: ${UNKNOWN_ARGS[*]}"
                            fi
                            sed 's/:/-/g' "${TOUCAN_FILE}" > "${TOUCAN_FILE}.tmp" && mv "${TOUCAN_FILE}.tmp" "${TOUCAN_FILE}"
                            echo "✅ Done replacing characters."
                            """
                    )
                }
                Mocks.E2E.templates(debugContext: "{{.}}")
            }
        }
        .test {
            let workDir = $1.appendingPathIfPresent("src")
            let toucan = Toucan()
            try toucan.generate(
                workDir: workDir.path(),
                now: now
            )

            let distURL = workDir.appendingPathIfPresent("dist")

            let fileURL = distURL.appendingPathIfPresent("test/index.html")
            let html = try String(contentsOf: fileURL, encoding: .utf8)

            #expect(html.contains("Character to replace => -"))
        }
    }

    @Test
    func paginationPages() throws {
        let now = Date()

        try FileManagerPlayground {
            Mocks.E2E.src(now: now)
        }
        .test {
            let workDir = $1.appendingPathIfPresent("src")
            let toucan = Toucan()
            try toucan.generate(
                workDir: workDir.path(),
                now: now
            )

            let distURL = workDir.appendingPathIfPresent("dist")

            let fileURL1 = distURL.appendingPathIfPresent(
                "blog/posts/pages/1/index.html"
            )
            let html1 = try String(contentsOf: fileURL1, encoding: .utf8)
            #expect(html1.contains("<title>Post pagination page 1 / 2</title>"))
            #expect(html1.contains("<h1>Post pagination page 1 / 2</h1>"))

            let fileURL2 = distURL.appendingPathIfPresent(
                "blog/posts/pages/2/index.html"
            )
            let html2 = try String(contentsOf: fileURL2, encoding: .utf8)

            #expect(html2.contains("<title>Post pagination page 2 / 2</title>"))
            #expect(html2.contains("<h1>Post pagination page 2 / 2</h1>"))
        }
    }

    @Test
    func scopeBasics() async throws {
        let now = Date()

        try FileManagerPlayground {
            Directory(name: "src") {
                mockSiteYAMLFile()
                Directory(name: "pipelines") {
                    YAMLFile(
                        name: "test",
                        contents: Pipeline(
                            id: "test",
                            scopes: [
                                "test": [
                                    "minimal": .init(
                                        context: .properties,
                                        fields: [
                                            "slug"
                                        ]
                                    ),
                                    "detail": .init(
                                        context: .detail,
                                        fields: [
                                            "title",
                                            "slug",
                                        ]
                                    ),
                                ]
                            ],
                            queries: [
                                "minimal": .init(
                                    contentType: "test",
                                    scope: "minimal"
                                )
                            ],
                            engine: .init(
                                id: "json"
                            ),
                            output: .init(
                                path: "",
                                file: "context",
                                ext: "json"
                            )
                        )
                    )
                }
                mockTestTypes()
                Directory(name: "contents") {
                    Directory(name: "test") {
                        MarkdownFile(
                            name: "index",
                            markdown: .init(
                                frontMatter: [
                                    "title": "Test",
                                    "type": "test",
                                    "foo": "bar",
                                ]
                            )
                        )
                    }
                }
            }
        }
        .test {
            let workDir = $1.appendingPathIfPresent("src")
            let toucan = Toucan()
            try toucan.generate(
                workDir: workDir.path(),
                now: now
            )

            let distURL = workDir.appendingPathIfPresent("dist")
            let contextURL = distURL.appendingPathIfPresent("context.json")
            let data = try Data(contentsOf: contextURL)

            let decoder = JSONDecoder()

            struct Exp: Decodable {
                struct Page: Decodable {
                    let slug: String
                    let title: String
                }

                struct Context: Decodable {
                    struct Minimal: Decodable {
                        let slug: String
                    }

                    let minimal: [Minimal]
                }

                let page: Page
                let context: Context
            }

            let exp = try decoder.decode(Exp.self, from: data)
            #expect(exp.page.title == "Test")
            #expect(exp.page.slug == "test")

            #expect(exp.context.minimal.count == 1)
            let first = try #require(exp.context.minimal.first)
            #expect(first.slug == "test")
        }
    }

    @Test
    func localizedDateOutputConfig() throws {
        let now = Date()

        try FileManagerPlayground {
            Directory(name: "src") {
                YAMLFile(
                    name: "toucan",
                    contents: TargetConfig(
                        targets: [
                            .standard
                        ]
                    )
                )
                YAMLFile(
                    name: "config",
                    contents: Config(
                        site: .defaults,
                        pipelines: .defaults,
                        contents: .defaults,
                        types: .defaults,
                        blocks: .defaults,
                        templates: .defaults,
                        dataTypes: .init(
                            date: .init(
                                input: .defaults,
                                output: .init(
                                    locale: "de-DE",
                                    timeZone: "CET"
                                ),
                                formats: [:]
                            )
                        ),
                        renderer: .defaults
                    )
                )
                YAMLFile(
                    name: "site",
                    contents: Settings(
                        [
                            "name": "Test site name",
                            "description": "Test site description",
                            "language": "de-DE",
                        ]
                    )
                )
                Directory(name: "pipelines") {
                    YAMLFile(
                        name: "test",
                        contents: Pipeline(
                            id: "test",
                            engine: .init(
                                id: "json",
                                options: [:]
                            ),
                            output: .init(
                                path: "",
                                file: "context",
                                ext: "json"
                            )
                        )
                    )
                }
                Directory(name: "types") {
                    YAMLFile(
                        name: "test",
                        contents: ContentType(
                            id: "test",
                            default: true,
                            properties: [
                                "publication": .init(
                                    propertyType: .date(config: nil),
                                    isRequired: true
                                )
                            ]
                        )
                    )
                }
                Directory(name: "contents") {
                    Directory(name: "test") {
                        MarkdownFile(
                            name: "index",
                            markdown: .init(
                                frontMatter: [
                                    "title": "Test",
                                    "type": "test",
                                    "publication": "2025-03-30T09:23:14.870Z",
                                ]
                            )
                        )
                    }
                }
            }
        }
        .test {
            let workDir = $1.appendingPathIfPresent("src")
            let toucan = Toucan()
            try toucan.generate(
                workDir: workDir.path(),
                now: now
            )

            let distURL = workDir.appendingPathIfPresent("dist")
            let contextURL = distURL.appendingPathIfPresent("context.json")
            let data = try Data(contentsOf: contextURL)

            let decoder = JSONDecoder()

            struct Exp: Decodable {
                struct Page: Decodable {
                    let slug: String
                    let title: String
                    let publication: DateContext
                }
                let page: Page
            }

            let exp = try decoder.decode(Exp.self, from: data)
            #expect(exp.page.title == "Test")
            #expect(exp.page.slug == "test")
            #expect(exp.page.publication.date.full == "Sonntag, 30. März 2025")
        }
    }

    @Test
    func localizedDateOutputConfigPipelineOverride() throws {
        let now = Date()

        try FileManagerPlayground {
            Directory(name: "src") {
                YAMLFile(
                    name: "toucan",
                    contents: TargetConfig(
                        targets: [
                            .standard
                        ]
                    )
                )
                YAMLFile(
                    name: "config",
                    contents: Config(
                        dataTypes: .init(
                            date: .init(
                                input: .defaults,
                                output: .init(
                                    locale: "de-DE",
                                    timeZone: "CET"
                                ),
                                formats: [:]
                            )
                        ),
                        renderer: .defaults
                    )
                )
                YAMLFile(
                    name: "site",
                    contents: Settings(
                        [
                            "name": "Test site name",
                            "description": "Test site description",
                            "language": "de-DE",
                        ]
                    )
                )
                Directory(name: "pipelines") {
                    YAMLFile(
                        name: "test",
                        contents: Pipeline(
                            id: "test",
                            dataTypes: .init(
                                date: .init(
                                    output: .init(
                                        locale: "hu-HU",
                                        timeZone: "CET"
                                    ),
                                    formats: [:]
                                )
                            ),
                            engine: .init(
                                id: "json",
                                options: [:]
                            ),
                            output: .init(
                                path: "",
                                file: "context",
                                ext: "json"
                            )
                        )
                    )
                }
                Directory(name: "types") {
                    YAMLFile(
                        name: "test",
                        contents: ContentType(
                            id: "test",
                            default: true,
                            properties: [
                                "publication": .init(
                                    propertyType: .date(config: nil),
                                    isRequired: true
                                )
                            ]
                        )
                    )
                }
                Directory(name: "contents") {
                    Directory(name: "test") {
                        MarkdownFile(
                            name: "index",
                            markdown: .init(
                                frontMatter: [
                                    "title": "Test",
                                    "type": "test",
                                    "publication": "2025-03-30T09:23:14.870Z",
                                ]
                            )
                        )
                    }
                }
            }
        }
        .test {
            let workDir = $1.appendingPathIfPresent("src")
            let toucan = Toucan()
            try toucan.generate(
                workDir: workDir.path(),
                now: now
            )

            let distURL = workDir.appendingPathIfPresent("dist")
            let contextURL = distURL.appendingPathIfPresent("context.json")
            let data = try Data(contentsOf: contextURL)

            let decoder = JSONDecoder()

            struct Exp: Decodable {
                struct Page: Decodable {
                    let slug: String
                    let title: String
                    let publication: DateContext
                }
                let page: Page
            }

            let exp = try decoder.decode(Exp.self, from: data)
            #expect(exp.page.title == "Test")
            #expect(exp.page.slug == "test")
            #expect(
                exp.page.publication.date.full == "2025. március 30., vasárnap"
            )
        }
    }
}
