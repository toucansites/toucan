//
//  SourceBundleScopeTestSuite.swift
//  Toucan
//
//  Created by Tibor Bodecs on 2025. 02. 21..
//

import Foundation
import Testing
import ToucanModels
import ToucanContent
import ToucanTesting
import Logging
@testable import ToucanSource

@Suite
struct SourceBundleScopeTestSuite {

    @Test
    func testScopes() throws {
        let logger = Logger(label: "SourceBundleScopeTestSuite")
        let now = Date()

        let settings = Settings.defaults
        let config = Config.defaults
        let sourceConfig = SourceConfig(
            sourceUrl: .init(fileURLWithPath: ""),
            config: config
        )
        let formatter = settings.dateFormatter(
            sourceConfig.config.dateFormats.input
        )

        let pipelines: [Pipeline] = [
            .init(
                id: "test",
                scopes: [
                    "post": [
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
                    ],
                    "page": [
                        "detail": .init(
                            context: .detail,
                            fields: [
                                "title",
                                "slug",
                            ]
                        )
                    ],
                ],
                queries: [
                    "featured": .init(
                        contentType: "post",
                        scope: "minimal"
                    )
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
        ]

        // posts
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
        // pages
        let pageDefinition = ContentDefinition.Mocks.page()
        let rawPageContents: [RawContent] = [
            .init(
                origin: .init(
                    path: "",
                    slug: ""
                ),
                frontMatter: [
                    "title": "Home",
                    "description": "Home description",
                    "foo": ["bar": "baz"],
                ],
                markdown: """
                    # Home

                    Lorem ipsum dolor sit amet
                    """,
                lastModificationDate: Date().timeIntervalSince1970,
                assets: []
            )
        ]
        let pageContents = rawPageContents.map {
            let converter = ContentDefinitionConverter(
                contentDefinition: pageDefinition,
                dateFormatter: formatter,
                logger: logger
            )
            return converter.convert(rawContent: $0)
        }

        let contents =
            postContents + pageContents

        let blockDirectives = MarkdownBlockDirective.Mocks.highlightedTexts()
        let templates: [String: String] = [
            "sitemap": Templates.Mocks.sitemap()
        ]

        let sourceBundle = SourceBundle(
            location: .init(filePath: ""),
            config: config,
            sourceConfig: sourceConfig,
            settings: settings,
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
            .sorted {
                $0.destination.path < $1.destination.path
            }

        #expect(results.count == 2)

        let decoder = JSONDecoder()

        struct Exp0: Decodable {
            struct Slug: Decodable {
                let value: String
            }
            struct Ctx: Decodable {
                struct Item: Decodable {
                    let slug: Slug
                    let isCurrentURL: Bool?
                }
                let featured: [Item]
            }
            struct Post: Decodable {
                let slug: Slug
                let isCurrentURL: Bool?
            }
            let page: Post
            let context: Ctx
        }

        let data0 = try #require(results[0].contents.data(using: .utf8))
        let exp0 = try decoder.decode(Exp0.self, from: data0)

        #expect(exp0.context.featured.allSatisfy { $0.isCurrentURL == nil })

        struct Exp1: Decodable {
            struct Slug: Decodable {
                let value: String
            }
            struct Ctx: Decodable {
                struct Item: Decodable {
                    let slug: Slug
                    let isCurrentURL: Bool?
                }

                let featured: [Item]
            }
            struct Page: Decodable {
                let slug: Slug
                let title: String
                let isCurrentURL: Bool?
            }
            let page: Page
            let context: Ctx
        }

        let data1 = try #require(results[1].contents.data(using: .utf8))
        let exp1 = try decoder.decode(Exp1.self, from: data1)
        #expect(exp1.context.featured.allSatisfy { $0.isCurrentURL == nil })
    }
}
