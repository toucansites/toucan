//
//  BuildTargetSourceRendererTestSuite.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 06. 09..
//

import Foundation
import Testing
import Logging
import ToucanCore
import ToucanSource
@testable import ToucanSDK

@Suite
struct BuildTargetSourceRendererTestSuite {

    @Test
    func emptyContentTypes() throws {
        let now = Date()
        let buildTargetSource = BuildTargetSource(
            locations: .init(
                sourceUrl: .init(filePath: ""),
                config: .defaults
            )
        )

        var renderer = BuildTargetSourceRenderer(
            buildTargetSource: buildTargetSource,
            templates: [:],
            generatorInfo: .current
        )

        let results = try renderer.render(now: now)
    }

    @Test()
    func generatorMetadata() async throws {
        let now = Date()
        let config = Config.defaults
        let target = Target.standard
        let settings = Settings.defaults

        let dateFormatter = ToucanOutputDateFormatter(
            dateConfig: config.dataTypes.date
        )
        let nowISO8601String = dateFormatter.format(now).iso8601

        let pipelines: [Pipeline] = [
            .init(
                id: "test",
                definesType: false,
                scopes: [:],
                queries: [:],
                dataTypes: .defaults,
                contentTypes: .defaults,
                iterators: [:],
                assets: .defaults,
                transformers: [:],
                engine: .init(id: "json", options: [:]),
                output: .init(path: "", file: "context", ext: "json")
            )
        ]

        let rawContents: [RawContent] = [
            .init(
                origin: .init(
                    path: .init(""),
                    slug: ""
                ),
                markdown: .init(
                    frontMatter: [
                        "title": "Home",
                        "description": "Home description",
                        "foo": [
                            "bar": "baz"
                        ],
                    ],
                    contents: """
                        # Home

                        Lorem ipsum dolor sit amet
                        """
                ),
                lastModificationDate: now.timeIntervalSince1970,
                assets: []
            )
        ]

        let buildTargetSource = BuildTargetSource(
            locations: .init(
                sourceUrl: .init(filePath: ""),
                config: config
            ),
            target: target,
            config: config,
            settings: settings,
            pipelines: pipelines,
            contentDefinitions: [
                Mocks.ContentDefinitions.page()
            ],
            rawContents: rawContents,
            blockDirectives: []
        )

        var renderer = BuildTargetSourceRenderer(
            buildTargetSource: buildTargetSource,
            templates: [:]
        )
        let results = try renderer.render(now: now)

        #expect(results.count == 1)
        guard case let .content(value) = results[0].source else {
            Issue.record("Source type is not a valid content.")
            return
        }

        let decoder = JSONDecoder()

        struct Exp: Decodable {
            struct Site: Codable {

            }
            let site: Site
            let generation: DateContext
            let generator: GeneratorInfo
        }

        //        print(value)

        let data = try #require(value.data(using: .utf8))
        let exp = try decoder.decode(Exp.self, from: data)
        let info = GeneratorInfo.current

        #expect(exp.generator.name == info.name)
        #expect(exp.generator.version == info.version)
        #expect(exp.generation.iso8601 == nowISO8601String)
    }

    @Test()
    func queryFilter() async throws {
        let now = Date()
        let config = Config.defaults
        let target = Target.standard
        let settings = Settings.defaults

        let dateFormatter = ToucanOutputDateFormatter(
            dateConfig: config.dataTypes.date
        )
        let nowISO8601String = dateFormatter.format(now).iso8601

        let pipelines: [Pipeline] = [
            .init(
                id: "test",
                definesType: false,
                scopes: [:],
                queries: [:],
                dataTypes: .defaults,
                contentTypes: .defaults,
                iterators: [:],
                assets: .defaults,
                transformers: [:],
                engine: .init(id: "json", options: [:]),
                output: .init(path: "", file: "context", ext: "json")
            )
        ]

        let rawContents: [RawContent] = [
            .init(
                origin: .init(
                    path: .init(""),
                    slug: ""
                ),
                markdown: .init(
                    frontMatter: [
                        "title": "Home",
                        "description": "Home description",
                        "foo": [
                            "bar": "baz"
                        ],
                    ],
                    contents: """
                        # Home

                        Lorem ipsum dolor sit amet
                        """
                ),
                lastModificationDate: now.timeIntervalSince1970,
                assets: []
            )
        ]

        var buildTargetSource = Mocks.buildTargetSource(now: now)
        // keep only html pipeline, exclude sitemap & rss xml contents
        buildTargetSource.pipelines = [
            Mocks.Pipelines.html()
        ]
        buildTargetSource.rawContents = buildTargetSource.rawContents.filter {
            !$0.origin.path.value.hasSuffix("xml")
        }

        //        let buildTargetSource = BuildTargetSource(
        //            locations: .init(
        //                sourceUrl: .init(filePath: ""),
        //                config: config
        //            ),
        //            target: target,
        //            config: config,
        //            settings: settings,
        //            pipelines: pipelines,
        //            contentDefinitions: [
        //                Mocks.ContentDefinitions.page()
        //            ],
        //            rawContents: rawContents,
        //            blockDirectives: []
        //        )

        let templates: [String: String] = [
            "html": Mocks.Templates.html(),
            "redirect": Mocks.Templates.redirect(),
            "rss": Mocks.Templates.rss(),
            "sitemap": Mocks.Templates.sitemap(),

            "pages.default": Mocks.Templates.page(),
            "pages.404": Mocks.Templates.notFound(),
            "pages.context": Mocks.Templates.context(value: "{{.}}"),

            "docs.category.default": Mocks.Templates.category(),
            "docs.guide.default": Mocks.Templates.guide(),

            "blog.post.default": Mocks.Templates.post(),
            "blog.author.default": Mocks.Templates.author(),
            "blog.tag.default": Mocks.Templates.tag(),

            "partials.blog.author": Mocks.Templates.partialAuthor(),
            "partials.blog.tag": Mocks.Templates.partialTag(),
            "partials.blog.post": Mocks.Templates.partialPost(),

            "partials.docs.category": Mocks.Templates.partialCategory(),
            "partials.docs.guide": Mocks.Templates.partialGuide(),
        ]

        var renderer = BuildTargetSourceRenderer(
            buildTargetSource: buildTargetSource,
            templates: templates
        )
        let results = try renderer.render(now: now)

        dump(results.filter { $0.source.isContent }.map { $0.destination.path })

        let context = results.filter { $0.source.isContent }
            .first { $0.destination.path == "context" }

        guard case let .content(value) = context?.source else {
            Issue.record("Source type is not a valid content.")
            return
        }

        print(value.replacingOccurrences(["&quot;": "\""]))
    }
}
