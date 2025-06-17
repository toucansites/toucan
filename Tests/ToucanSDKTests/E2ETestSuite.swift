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
            let notFoundURL = output.appendingPathIfPresent("404.html")
            let notFound = try String(contentsOf: notFoundURL)

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

            #expect(
                context
                    .replacingOccurrences(
                        [
                            "&quot;": "\"",
                        ]
                    )
                    .contains("Context page description")
            )
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
                                    ),
                                ]
                            ),
                            transformers: [:],
                            engine: .init(
                                id: "json",
                                options: [
                                    "keyPath": "page",
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
                        contents: ContentType(
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
                                    "type": "test",
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
                                    ),
                                ]
                            ),
                            transformers: [:],
                            engine: .init(
                                id: "json",
                                options: [
                                    "keyPath": "page",
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
                        contents: ContentType(
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
                                    "type": "test",
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
                                    ),
                                ]
                            ),
                            transformers: [:],
                            engine: .init(
                                id: "json",
                                options: [
                                    "keyPath": "page",
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
                        contents: ContentType(
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
                                    "type": "test",
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
                                    ),
                                ]
                            ),
                            transformers: [:],
                            engine: .init(
                                id: "json",
                                options: [
                                    "keyPath": "page",
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
                        contents: ContentType(
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
                                    "type": "test",
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
    func minifyCSSAsset() async throws {
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
                                    ),
                                ],
                                properties: []
                            ),
                            transformers: [:],
                            engine: .init(
                                id: "json",
                                options: [
                                    "keyPath": "page",
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
                        contents: ContentType(
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
                                    "type": "test",
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
    func sASSAsset() async throws {
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
                                    ),
                                ],
                                properties: []
                            ),
                            transformers: [:],
                            engine: .init(
                                id: "json",
                                options: [
                                    "keyPath": "page",
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
                        contents: ContentType(
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
                                    "type": "test",
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
    func sCSSModuleLoader() async throws {
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
                                    ),
                                ],
                                properties: []
                            ),
                            transformers: [:],
                            engine: .init(
                                id: "json",
                                options: [
                                    "keyPath": "page",
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
                        contents: ContentType(
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
                                    "type": "test",
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

    @Test
    func transformerRunTest() async throws {
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
                            assets: .defaults,
                            transformers: [
                                "test": .init(
                                    run: [
                                        .init(
                                            path: "\(rootURL.path())/\(rootName)/src/transformers",
                                            name: "replace"
                                        ),
                                    ],
                                    isMarkdownResult: false
                                ),
                            ],
                            engine: .init(
                                id: "mustache",
                                options: [
                                    "contentTypes": [
                                        "test": [
                                            "template": "test",
                                        ],
                                    ],
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
                Directory(name: "types") {
                    YAMLFile(
                        name: "test",
                        contents: ContentType(
                            id: "test",
                            default: true
                        )
                    )
                }
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
            let input = $1.appendingPathIfPresent("src")
            try Toucan(input: input.path()).generate(now: now)

            let output = $1.appendingPathIfPresent("docs")

            let fileURL = output.appendingPathIfPresent("test/index.html")
            let html = try String(contentsOf: fileURL)

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
            let input = $1.appendingPathIfPresent("src")
            try Toucan(input: input.path()).generate(now: now)

            let output = $1.appendingPathIfPresent("docs")

            let fileURL1 = output.appendingPathIfPresent(
                "blog/posts/pages/1/index.html"
            )
            let html1 = try String(contentsOf: fileURL1)
            #expect(html1.contains("<title>Post pagination page 1 / 2</title>"))
            #expect(html1.contains("<h1>Post pagination page 1 / 2</h1>"))

            let fileURL2 = output.appendingPathIfPresent(
                "blog/posts/pages/2/index.html"
            )
            let html2 = try String(contentsOf: fileURL2)

            #expect(html2.contains("<title>Post pagination page 2 / 2</title>"))
            #expect(html2.contains("<h1>Post pagination page 2 / 2</h1>"))
        }
    }

    @Test
    func scopeBasics() async throws {
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
                            scopes: [
                                "test": [
                                    "minimal": .init(
                                        context: .properties,
                                        fields: [
                                            "slug",
                                        ]
                                    ),
                                    "detail": .init(
                                        context: .detail,
                                        fields: [
                                            "title",
                                            "slug",
                                        ]
                                    ),
                                ],
                            ],
                            queries: [
                                "minimal": .init(
                                    contentType: "test",
                                    scope: "minimal"
                                ),
                            ],
                            dataTypes: .defaults,
                            contentTypes: .defaults,
                            iterators: [:],
                            assets: .defaults,
                            transformers: [:],
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
                            default: true
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
                                    "foo": "bar",
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
}
