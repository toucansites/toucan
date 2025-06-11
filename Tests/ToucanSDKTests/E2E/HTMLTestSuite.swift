//
//  HTMLTestSuite.swift
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
struct HTMLTestSuite {

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
