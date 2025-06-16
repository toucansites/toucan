//
//  E2ETestSuite.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 06. 11..
//

import Foundation
import Testing
import Logging
import ToucanCore
import ToucanSource
import FileManagerKitBuilder
@testable import ToucanSDK

@Suite
struct E2ETestSuite {

    // MARK: - html files

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
            try Toucan(input: input.path()).generate(now: now)

            let output = $1.appendingPathIfPresent("docs")
            let notFoundUrl = output.appendingPathIfPresent("404.html")
            let notFound = try String(contentsOf: notFoundUrl)

            #expect(notFound.contains("Not found page contents"))
        }
    }

    // MARK: non-html files

    @Test
    func rss() throws {
        let now = Date()

        try FileManagerPlayground {
            Mocks.E2E.src(now: now)
        }
        .test {
            let input = $1.appendingPathIfPresent("src")
            try Toucan(input: input.path()).generate(now: now)

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
            try Toucan(input: input.path()).generate(now: now)

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
            try Toucan(input: input.path()).generate(now: now)

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

    // MARK: - other tests

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
            try Toucan(input: input.path()).generate(now: now)

            let output = $1.appendingPathIfPresent("docs")
            let contextURL = output.appendingPathIfPresent("context/index.html")
            let context = try String(contentsOf: contextURL)

            print(context.replacingOccurrences(["&quot;": "\""]))

        }
    }

    // MARK: - assets

    @Test
    func loadOneSVGFile() async throws {
        let now = Date()

        try FileManagerPlayground {
            Directory(name: "src") {
                YAMLFile(
                    name: "site",
                    contents: [
                        "name": "Test site name",
                        "description": "Test site description",
                        "language": "en-US",
                    ] as [String: AnyCodable]
                )
                Directory(name: "pipelines") {
                    YAMLFile(
                        name: "test",
                        contents: Pipeline(
                            id: "test",
                            definesType: false,
                            scopes: [:],
                            queries: [:],
                            dataTypes: .defaults,
                            contentTypes: .defaults,
                            iterators: [:],
                            assets: .init(
                                behaviors: [],
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
                Directory(name: "types") {
                    YAMLFile(
                        name: "test",
                        contents: ContentDefinition(
                            id: "test",
                            default: true
                        )
                    )
                }
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
            let input = $1.appendingPathIfPresent("src")
            try Toucan(input: input.path()).generate(now: now)

            let output = $1.appendingPathIfPresent("docs")
            let contextURL = output.appendingPathIfPresent("context.json")
            //            let context = try String(contentsOf: contextURL)
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
                YAMLFile(
                    name: "site",
                    contents: [
                        "name": "Test site name",
                        "description": "Test site description",
                        "language": "en-US",
                    ] as [String: AnyCodable]
                )
                Directory(name: "pipelines") {
                    YAMLFile(
                        name: "test",
                        contents: Pipeline(
                            id: "test",
                            definesType: false,
                            scopes: [:],
                            queries: [:],
                            dataTypes: .defaults,
                            contentTypes: .defaults,
                            iterators: [:],
                            assets: .init(
                                behaviors: [],
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
                Directory(name: "types") {
                    YAMLFile(
                        name: "test",
                        contents: ContentDefinition(
                            id: "test",
                            default: true
                        )
                    )
                }
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
            let input = $1.appendingPathIfPresent("src")
            try Toucan(input: input.path()).generate(now: now)

            let output = $1.appendingPathIfPresent("docs")
            let contextURL = output.appendingPathIfPresent("context.json")
            //            let context = try String(contentsOf: contextURL)
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
                YAMLFile(
                    name: "site",
                    contents: [
                        "name": "Test site name",
                        "description": "Test site description",
                        "language": "en-US",
                    ] as [String: AnyCodable]
                )
                Directory(name: "pipelines") {
                    YAMLFile(
                        name: "test",
                        contents: Pipeline(
                            id: "test",
                            definesType: false,
                            scopes: [:],
                            queries: [:],
                            dataTypes: .defaults,
                            contentTypes: .defaults,
                            iterators: [:],
                            assets: .init(
                                behaviors: [],
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
                Directory(name: "types") {
                    YAMLFile(
                        name: "test",
                        contents: ContentDefinition(
                            id: "test",
                            default: true
                        )
                    )
                }
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
            let input = $1.appendingPathIfPresent("src")
            try Toucan(input: input.path()).generate(now: now)

            let output = $1.appendingPathIfPresent("docs")
            let contextURL = output.appendingPathIfPresent("context.json")
            //            let context = try String(contentsOf: contextURL)
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
                YAMLFile(
                    name: "site",
                    contents: [
                        "name": "Test site name",
                        "description": "Test site description",
                        "language": "en-US",
                    ] as [String: AnyCodable]
                )
                Directory(name: "pipelines") {
                    YAMLFile(
                        name: "test",
                        contents: Pipeline(
                            id: "test",
                            definesType: false,
                            scopes: [:],
                            queries: [:],
                            dataTypes: .defaults,
                            contentTypes: .defaults,
                            iterators: [:],
                            assets: .init(
                                behaviors: [],
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
                Directory(name: "types") {
                    YAMLFile(
                        name: "test",
                        contents: ContentDefinition(
                            id: "test",
                            default: true
                        )
                    )
                }
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
            let input = $1.appendingPathIfPresent("src")
            try Toucan(input: input.path()).generate(now: now)

            let output = $1.appendingPathIfPresent("docs")
            let contextURL = output.appendingPathIfPresent("context.json")
            //            let context = try String(contentsOf: contextURL)
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
    func testMinifyCSSAsset() async throws {
        let now = Date()

        try FileManagerPlayground {
            Directory(name: "src") {
                YAMLFile(
                    name: "site",
                    contents: [
                        "name": "Test site name",
                        "description": "Test site description",
                        "language": "en-US",
                    ] as [String: AnyCodable]
                )
                Directory(name: "pipelines") {
                    YAMLFile(
                        name: "test",
                        contents: Pipeline(
                            id: "test",
                            definesType: false,
                            scopes: [:],
                            queries: [:],
                            dataTypes: .defaults,
                            contentTypes: .defaults,
                            iterators: [:],
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
                                ],
                                properties: []
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
                Directory(name: "types") {
                    YAMLFile(
                        name: "test",
                        contents: ContentDefinition(
                            id: "test",
                            default: true
                        )
                    )
                }
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
            let input = $1.appendingPathIfPresent("src")
            try Toucan(input: input.path()).generate(now: now)

            let output = $1.appendingPathIfPresent("docs")
            let cssURL = output.appendingPathIfPresent(
                "assets/test/style.min.css"
            )

            let css = try String(contentsOf: cssURL)

            #expect(
                css.contains(
                    "html{margin:0;padding:0}body{background:red}"
                )
            )
        }
    }

    @Test
    func testSASSAsset() async throws {
        let now = Date()

        try FileManagerPlayground {
            Directory(name: "src") {
                YAMLFile(
                    name: "site",
                    contents: [
                        "name": "Test site name",
                        "description": "Test site description",
                        "language": "en-US",
                    ] as [String: AnyCodable]
                )
                Directory(name: "pipelines") {
                    YAMLFile(
                        name: "test",
                        contents: Pipeline(
                            id: "test",
                            definesType: false,
                            scopes: [:],
                            queries: [:],
                            dataTypes: .defaults,
                            contentTypes: .defaults,
                            iterators: [:],
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
                                ],
                                properties: []
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
                Directory(name: "types") {
                    YAMLFile(
                        name: "test",
                        contents: ContentDefinition(
                            id: "test",
                            default: true
                        )
                    )
                }
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
            let input = $1.appendingPathIfPresent("src")
            try Toucan(input: input.path()).generate(now: now)

            let output = $1.appendingPathIfPresent("docs")
            let cssURL = output.appendingPathIfPresent(
                "assets/test/style.css"
            )

            let css = try String(contentsOf: cssURL)

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
    func testSCSSModuleLoader() async throws {
        let now = Date()

        try FileManagerPlayground {
            Directory(name: "src") {
                YAMLFile(
                    name: "site",
                    contents: [
                        "name": "Test site name",
                        "description": "Test site description",
                        "language": "en-US",
                    ] as [String: AnyCodable]
                )
                Directory(name: "pipelines") {
                    YAMLFile(
                        name: "test",
                        contents: Pipeline(
                            id: "test",
                            definesType: false,
                            scopes: [:],
                            queries: [:],
                            dataTypes: .defaults,
                            contentTypes: .defaults,
                            iterators: [:],
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
                                ],
                                properties: []
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
                Directory(name: "types") {
                    YAMLFile(
                        name: "test",
                        contents: ContentDefinition(
                            id: "test",
                            default: true
                        )
                    )
                }
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
            let input = $1.appendingPathIfPresent("src")
            try Toucan(input: input.path()).generate(now: now)

            let output = $1.appendingPathIfPresent("docs")
            let cssURL = output.appendingPathIfPresent(
                "assets/test/style.css"
            )

            let css = try String(contentsOf: cssURL)

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

    // MARK: - transformers

    //    @Test
    //    func transformerRunTest() async throws {
    //        let logger = Logger(label: "ToucanTestSuite")
    //        let fileManager = FileManager.default
    //        let rootUrl = FileManager.default.temporaryDirectory
    //        let rootName = "FileManagerPlayground_\(UUID().uuidString)"
    //
    //        try FileManagerPlayground(
    //            rootUrl: rootUrl,
    //            rootName: rootName,
    //            fileManager: fileManager
    //        ) {
    //            Directory(name: "src") {
    //                Directory(name: "contents") {
    //                    contentAbout()
    //                    Directory(name: "assets") {
    //                        contentStyleCss()
    //                    }
    //                    contentHome()
    //                    Directory(name: "page1") {
    //                        File(
    //                            name: "index.yaml",
    //                            string: """
    //                                type: page
    //                                description: Desc1
    //                                label: label1
    //                                """
    //                        )
    //                        File(
    //                            name: "index.md",
    //                            string: """
    //                                ---
    //                                title: "First beta release"
    //                                ---
    //                                Character to replace => :
    //                                """
    //                        )
    //                    }
    //                    contentSiteFile()
    //                }
    //                Directory(name: "pipelines") {
    //                    pipelineHtml(rootUrl: rootUrl.path(), rootName: rootName)
    //                }
    //                Directory(name: "types") {
    //                    typePage()
    //                }
    //                Directory(name: "themes") {
    //                    Directory(name: "default") {
    //                        Directory(name: "templates") {
    //                            Directory(name: "pages") {
    //                                themeDefaultMustache()
    //                            }
    //                            themeHtmlMustache()
    //                        }
    //                    }
    //                }
    //                Directory(name: "transformers") {
    //                    replaceScriptFile()
    //                }
    //                configFile()
    //            }
    //        }
    //        .test {
    //            let input = $1.appending(path: "src/")
    //            let output = $1.appending(path: "docs/")
    //            try getToucan(input, output, logger).generate()
    //
    //            let page1 = output.appending(path: "page1/index.html")
    //            let data = try page1.loadContents()
    //            #expect(data.contains("Character to replace => -"))
    //        }
    //    }
    //
    //    @Test
    //    func testPageLink() throws {
    //        let logger = Logger(label: "BuildTargetSourcePageLinkTestSuite")
    //        let target = Target.standard
    //        let now = Date()
    //
    //        let pipelines: [Pipeline] = [
    //            .init(
    //                id: "html",
    //                scopes: [
    //                    "*": [
    //                        "detail": Pipeline.Scope(
    //                            context: Pipeline.Scope.Context(rawValue: 31),
    //                            fields: []
    //                        ),
    //                        "list": Pipeline.Scope(
    //                            context: Pipeline.Scope.Context(rawValue: 11),
    //                            fields: []
    //                        ),
    //                        "reference": Pipeline.Scope(
    //                            context: Pipeline.Scope.Context(rawValue: 3),
    //                            fields: []
    //                        ),
    //                    ]
    //                ],
    //                queries: [
    //                    "featured": .init(
    //                        contentType: "post",
    //                        scope: "list"
    //                    )
    //                ],
    //                dataTypes: .defaults,
    //                contentTypes: .defaults,
    //                iterators: [
    //                    "post.pagination": Query(
    //                        contentType: "post",
    //                        scope: "detail",
    //                        limit: 9,
    //                        offset: nil,
    //                        filter: nil,
    //                        orderBy: [
    //                            Order(
    //                                key: "publication",
    //                                direction: ToucanModels.Direction.desc
    //                            )
    //                        ]
    //                    )
    //                ],
    //                assets: .defaults,
    //                transformers: [:],
    //                engine: .init(
    //                    id: "mustache",
    //                    options: [:]
    //                ),
    //                output: .init(
    //                    path: "{{slug}}",
    //                    file: "index",
    //                    ext: "html"
    //                )
    //            )
    //        ]
    //
    //        let postContent = Content(
    //            id: "post",
    //            slug: .init(value: "post"),
    //            rawValue: RawContent(
    //                origin: Origin(path: "", slug: "post"),
    //                frontMatter: [
    //                    "publication": .init("2025-01-10 01:02:03")
    //                ],
    //                markdown: "",
    //                lastModificationDate: 1742843632.8373249,
    //                assets: []
    //            ),
    //            definition: ContentDefinition(
    //                id: "post",
    //                default: false,
    //                paths: ["posts"],
    //                properties: [:],
    //                relations: [:],
    //                queries: [:]
    //            ),
    //            properties: [:],
    //            relations: [:],
    //            userDefined: [:],
    //            iteratorInfo: nil
    //        )
    //
    //        let paginationContent = Content(
    //            id: "{{post.pagination}}",
    //            slug: .init(value: "posts/page/{{post.pagination}}"),
    //            rawValue: RawContent(
    //                origin: Origin(
    //                    path: "posts/{{post.pagination}}/index.md",
    //                    slug: "{{post.pagination}}"
    //                ),
    //                frontMatter: [
    //                    "home": .init("posts/page"),
    //                    "title": .init("Posts - {{number}} / {{total}}"),
    //                    "slug": .init("posts/page/{{post.pagination}}"),
    //                    "description": .init("Posts page - {{number}} / {{total}}"),
    //                    "css": .init([]),
    //                    "js": .init([]),
    //                    "type": .init("page"),
    //                    "template": .init("posts"),
    //                    "image": nil,
    //                ],
    //                markdown: "Values in markdown: {{number}} / {{total}}",
    //                lastModificationDate: 1742843632.8373249,
    //                assets: []
    //            ),
    //            definition: ContentDefinition(
    //                id: "page",
    //                default: true,
    //                paths: [],
    //                properties: [
    //                    "title": Property(
    //                        propertyType: PropertyType.string,
    //                        isRequired: true,
    //                        defaultValue: nil
    //                    )
    //                ],
    //                relations: [:],
    //                queries: [:]
    //            ),
    //            properties: ["title": AnyCodable("Posts - {{number}} / {{total}}")],
    //            relations: [:],
    //            userDefined: [
    //                "home": .init("posts/page"),
    //                "description": .init("Posts page - {{number}} / {{total}}"),
    //                "css": .init([]),
    //                "js": .init([]),
    //                "template": .init("posts"),
    //                "image": nil,
    //            ],
    //            iteratorInfo: nil
    //        )
    //
    //        let contents: [Content] = [postContent, paginationContent]
    //        let templates: [String: String] = [
    //            "posts": Templates.Mocks.page()
    //        ]
    //
    //        let config = Config.defaults
    //        let sourceConfig = SourceLocations(
    //            sourceUrl: .init(fileURLWithPath: ""),
    //            config: config
    //        )
    //
    //        let buildTargetSource = BuildTargetSource(
    //            location: .init(filePath: ""),
    //            target: target,
    //            config: config,
    //            sourceConfig: sourceConfig,
    //            settings: .standard,
    //            pipelines: pipelines,
    //            contents: contents,
    //            blockDirectives: [],
    //            templates: templates,
    //            baseUrl: "http://localhost:3000"
    //        )
    //
    //        var renderer = BuildTargetSourceRenderer(
    //            buildTargetSource: buildTargetSource,
    //            fileManager: FileManager.default,
    //            logger: logger
    //        )
    //
    //        let results = try renderer.render(now: now)
    //
    //        #expect(results.count == 1)
    //        #expect(results[0].destination.path == "posts/page/1")
    //
    //        switch results[0].source {
    //        case .assetFile(_), .asset(_):
    //            #expect(Bool(false))
    //        case .content(let value):
    //            #expect(value.contains("<title>Posts - 1 / 1 - </title>"))
    //            #expect(value.contains("Values in markdown: 1 / 1"))
    //        }
    //    }
    //
    //    @Test
    //    func testScopes() throws {
    //        let logger = Logger(label: "BuildTargetSourceScopeTestSuite")
    //        let now = Date()
    //
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
    //        let pipelines: [Pipeline] = [
    //            .init(
    //                id: "test",
    //                scopes: [
    //                    "post": [
    //                        "minimal": .init(
    //                            context: .properties,
    //                            fields: [
    //                                "slug"
    //                            ]
    //                        ),
    //                        "detail": .init(
    //                            context: .detail,
    //                            fields: [
    //                                "title",
    //                                "slug",
    //                            ]
    //                        ),
    //                    ],
    //                    "page": [
    //                        "detail": .init(
    //                            context: .detail,
    //                            fields: [
    //                                "title",
    //                                "slug",
    //                            ]
    //                        )
    //                    ],
    //                ],
    //                queries: [
    //                    "featured": .init(
    //                        contentType: "post",
    //                        scope: "minimal"
    //                    )
    //                ],
    //                dataTypes: .defaults,
    //                contentTypes: .defaults,
    //                iterators: [:],
    //                assets: .defaults,
    //                transformers: [:],
    //                engine: .init(
    //                    id: "json",
    //                    options: [:]
    //                ),
    //                output: .init(
    //                    path: "",
    //                    file: "context",
    //                    ext: "json"
    //                )
    //            )
    //        ]
    //
    //        // posts
    //        let postDefinition = ContentDefinition.Mocks.post()
    //        let rawPostContents = RawContent.Mocks.posts(
    //            max: 1,
    //            now: now,
    //            formatter: formatter
    //        )
    //        let postContents = rawPostContents.map {
    //            let converter = ContentDefinitionConverter(
    //                contentDefinition: postDefinition,
    //                dateFormatter: formatter,
    //                logger: logger
    //            )
    //            return converter.convert(rawContent: $0)
    //        }
    //        // pages
    //        let pageDefinition = ContentDefinition.Mocks.page()
    //        let rawPageContents: [RawContent] = [
    //            .init(
    //                origin: .init(
    //                    path: "",
    //                    slug: ""
    //                ),
    //                frontMatter: [
    //                    "title": "Home",
    //                    "description": "Home description",
    //                    "foo": ["bar": "baz"],
    //                ],
    //                markdown: """
    //                    # Home
    //
    //                    Lorem ipsum dolor sit amet
    //                    """,
    //                lastModificationDate: Date().timeIntervalSince1970,
    //                assets: []
    //            )
    //        ]
    //        let pageContents = rawPageContents.map {
    //            let converter = ContentDefinitionConverter(
    //                contentDefinition: pageDefinition,
    //                dateFormatter: formatter,
    //                logger: logger
    //            )
    //            return converter.convert(rawContent: $0)
    //        }
    //
    //        let contents =
    //            postContents + pageContents
    //
    //        let blockDirectives = MarkdownBlockDirective.Mocks.highlightedTexts()
    //        let templates: [String: String] = [
    //            "sitemap": Templates.Mocks.sitemap()
    //        ]
    //
    //        let buildTargetSource = BuildTargetSource(
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
    //        var renderer = BuildTargetSourceRenderer(
    //            buildTargetSource: buildTargetSource,
    //            fileManager: FileManager.default,
    //            logger: logger
    //        )
    //        let results = try renderer.render(now: now)
    //            .sorted {
    //                $0.destination.path < $1.destination.path
    //            }
    //
    //        #expect(results.count == 2)
    //
    //        let decoder = JSONDecoder()
    //
    //        struct Exp0: Decodable {
    //            struct Slug: Decodable {
    //                let value: String
    //            }
    //            struct Ctx: Decodable {
    //                struct Item: Decodable {
    //                    let slug: Slug
    //                    let isCurrentURL: Bool?
    //                }
    //                let featured: [Item]
    //            }
    //            struct Post: Decodable {
    //                let slug: Slug
    //                let isCurrentURL: Bool?
    //            }
    //            let page: Post
    //            let context: Ctx
    //        }
    //
    //        switch results[0].source {
    //        case .assetFile(_), .asset(_):
    //            #expect(Bool(false))
    //        case .content(let value):
    //            let data0 = try #require(value.data(using: .utf8))
    //            let exp0 = try decoder.decode(Exp0.self, from: data0)
    //
    //            #expect(exp0.context.featured.allSatisfy { $0.isCurrentURL == nil })
    //        }
    //
    //        struct Exp1: Decodable {
    //            struct Slug: Decodable {
    //                let value: String
    //            }
    //            struct Ctx: Decodable {
    //                struct Item: Decodable {
    //                    let slug: Slug
    //                    let isCurrentURL: Bool?
    //                }
    //
    //                let featured: [Item]
    //            }
    //            struct Page: Decodable {
    //                let slug: Slug
    //                let title: String
    //                let isCurrentURL: Bool?
    //            }
    //            let page: Page
    //            let context: Ctx
    //        }
    //
    //        switch results[1].source {
    //        case .assetFile(_), .asset(_):
    //            #expect(Bool(false))
    //        case .content(let value):
    //            let data1 = try #require(value.data(using: .utf8))
    //            let exp1 = try decoder.decode(Exp1.self, from: data1)
    //            #expect(exp1.context.featured.allSatisfy { $0.isCurrentURL == nil })
    //        }
    //    }
}
