//
//  File.swift
//  toucan
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
struct SourceBundleContextTestSuite {

    @Test(.disabled("Disable for now to speed up generation process"))
    func isCurrentUrl() throws {
        let logger = Logger(label: "SourceBundleContextTestSuite")
        let formatter = DateFormatter.Mocks.en_US()
        let now = Date()

        let pipelines: [Pipeline] = [
            .init(
                id: "test",
                scopes: [:],
                queries: [
                    "featured": .init(
                        contentType: "post",
                        scope: "list"
                    )
                ],
                dataTypes: .defaults,
                contentTypes: .init(
                    include: [],
                    exclude: [],
                    lastUpdate: []
                ),
                iterators: [:],
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
                defaultDateFormat: "Y-MM-dd",
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
                defaultDateFormat: "Y-MM-dd",
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

        let config = Config.defaults
        let sourceConfig = SourceConfig(
            sourceUrl: .init(fileURLWithPath: ""),
            config: config
        )

        let sourceBundle = SourceBundle(
            location: .init(filePath: ""),
            config: config,
            sourceConfig: sourceConfig,
            settings: .defaults,
            pipelines: pipelines,
            contents: contents,
            blockDirectives: blockDirectives,
            templates: templates,
            baseUrl: ""
        )

        var renderer = SourceBundleRenderer(
            sourceBundle: sourceBundle,
            dateFormatter: formatter,
            fileManager: FileManager.default,
            logger: logger
        )
        let results = try renderer.renderPipelineResults(now: now)

        #expect(results.count == 2)

        let decoder = JSONDecoder()

        struct Exp0: Decodable {
            struct Ctx: Decodable {
                struct Item: Decodable {
                    let isCurrentURL: Bool
                    let slug: String
                }
                let featured: [Item]
            }
            struct Post: Decodable {
                let isCurrentURL: Bool
                let slug: String
            }
            let page: Post
            let context: Ctx
        }

        let data0 = try #require(results[0].contents.data(using: .utf8))
        let exp0 = try decoder.decode(Exp0.self, from: data0)

        #expect(exp0.page.isCurrentURL)
        for item in exp0.context.featured {
            #expect(item.isCurrentURL == (exp0.page.slug == item.slug))
        }

        struct Exp1: Decodable {
            struct Ctx: Decodable {
                struct Item: Decodable {
                    let isCurrentURL: Bool
                }

                let featured: [Item]
            }
            struct Page: Decodable {
                let isCurrentURL: Bool
            }
            let page: Page
            let context: Ctx
        }

        let data1 = try #require(results[1].contents.data(using: .utf8))
        let exp1 = try decoder.decode(Exp1.self, from: data1)

        #expect(exp1.page.isCurrentURL)
        #expect(exp1.context.featured.allSatisfy { !$0.isCurrentURL })
    }

    @Test(.disabled("Disable for now to speed up generation process"))
    func generatorMetadata() async throws {
        let logger = Logger(label: "SourceBundleContextTestSuite")
        let formatter = DateFormatter.Mocks.en_US()
        let isoFormatter = DateFormatter.Mocks
            .en_US("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'")
        let now = Date()

        let pipelines: [Pipeline] = [
            .init(
                id: "test",
                scopes: [:],
                queries: [:],
                dataTypes: .defaults,
                contentTypes: .init(
                    include: [],
                    exclude: [],
                    lastUpdate: []
                ),
                iterators: [:],
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
                defaultDateFormat: "Y-MM-dd",
                logger: logger
            )
            return converter.convert(rawContent: $0)
        }

        let contents = pageContents

        let config = Config.defaults
        let sourceConfig = SourceConfig(
            sourceUrl: .init(fileURLWithPath: ""),
            config: config
        )

        let sourceBundle = SourceBundle(
            location: .init(filePath: ""),
            config: config,
            sourceConfig: sourceConfig,
            settings: .defaults,
            pipelines: pipelines,
            contents: contents,
            blockDirectives: [],
            templates: [:],
            baseUrl: ""
        )

        var renderer = SourceBundleRenderer(
            sourceBundle: sourceBundle,
            dateFormatter: formatter,
            fileManager: FileManager.default,
            logger: logger
        )
        let results = try renderer.renderPipelineResults(now: now)

        #expect(results.count == 1)

        let decoder = JSONDecoder()

        struct Exp: Decodable {
            struct Site: Codable {
                let generation: DateFormats
                let generator: Generator
            }
            let site: Site
        }

        let data = try #require(results[0].contents.data(using: .utf8))
        let exp = try decoder.decode(Exp.self, from: data)

        #expect(exp.site.generator.name == "Toucan")
        #expect(exp.site.generator.version == "1.0.0-beta3")
        #expect(
            exp.site.generation.formats["iso8601"]
                == isoFormatter.string(from: now)
        )
    }
}
