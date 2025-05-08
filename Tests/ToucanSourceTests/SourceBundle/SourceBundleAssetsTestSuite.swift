//
//  SourceBundleAssetsTestSuite.swift
//  Toucan
//
//  Created by gerp83 on 2025. 04. 24..
//

import Foundation
import Testing
import ToucanModels
import ToucanContent
import ToucanTesting
import ToucanInfo
import Logging
@testable import ToucanSource

@Suite
struct SourceBundleAssetsTestSuite {

    @Test()
    func testSet() async throws {
        let pipelines: [Pipeline] = [
            .init(
                id: "test",
                scopes: [:],
                queries: [:],
                dataTypes: .defaults,
                contentTypes: .init(
                    include: ["page"],
                    exclude: [],
                    lastUpdate: [],
                    filterRules: [:]
                ),
                iterators: [:],
                assets: .init(
                    behaviors: [],
                    properties: [
                        .init(
                            action: .set,
                            property: "image",
                            resolvePath: true,
                            input: .init(
                                name: "cover",
                                ext: "jpg"
                            )
                        )
                    ]
                ),
                transformers: [:],
                engine: .init(
                    id: "mustache",
                    options: [
                        "contentTypes": [
                            "page": [
                                "template": "page"
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
        ]
        let rawPageContents: [RawContent] = [
            getRawContent(["cover.jpg"])
        ]
        var renderer = getRenderer(pipelines, rawPageContents)
        let results = try renderer.render(now: Date())

        #expect(results.count == 1)

        switch results[0].source {
        case .asset(_):
            #expect(Bool(false))
        case .content(let value):
            #expect(
                value.contains("http://localhost:3000/assets/slug/cover.jpg")
            )
        }
    }

    @Test()
    func testSetMore() async throws {
        let pipelines: [Pipeline] = [
            .init(
                id: "test",
                scopes: [:],
                queries: [:],
                dataTypes: .defaults,
                contentTypes: .init(
                    include: ["page"],
                    exclude: [],
                    lastUpdate: [],
                    filterRules: [:]
                ),
                iterators: [:],
                assets: .init(
                    behaviors: [],
                    properties: [
                        .init(
                            action: .set,
                            property: "image",
                            resolvePath: true,
                            input: .init(name: "*", ext: "png")
                        )
                    ]
                ),
                transformers: [:],
                engine: .init(
                    id: "mustache",
                    options: [
                        "contentTypes": [
                            "page": [
                                "template": "page"
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
        ]
        let rawPageContents: [RawContent] = [
            getRawContent(["custom1.png", "custom2.png"])
        ]
        var renderer = getRenderer(
            pipelines,
            rawPageContents,
            """
            <img src=\"{{page.image.custom1}}\">
            <img src=\"{{page.image.custom2}}\">
            """
        )
        let results = try renderer.render(now: Date())

        #expect(results.count == 1)
        switch results[0].source {
        case .asset(_):
            #expect(Bool(false))
        case .content(let value):
            #expect(
                value.contains("http://localhost:3000/assets/slug/custom1.png")
            )
            #expect(
                value.contains("http://localhost:3000/assets/slug/custom2.png")
            )
        }
    }

    @Test()
    func testAdd() async throws {
        let pipelines: [Pipeline] = [
            .init(
                id: "test",
                scopes: [:],
                queries: [:],
                dataTypes: .defaults,
                contentTypes: .init(
                    include: ["page"],
                    exclude: [],
                    lastUpdate: [],
                    filterRules: [:]
                ),
                iterators: [:],
                assets: .init(
                    behaviors: [],
                    properties: [
                        .init(
                            action: .add,
                            property: "image",
                            resolvePath: true,
                            input: .init(name: "custom", ext: "jpg")
                        )
                    ]
                ),
                transformers: [:],
                engine: .init(
                    id: "mustache",
                    options: [
                        "contentTypes": [
                            "page": [
                                "template": "page"
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
        ]
        let rawPageContents: [RawContent] = [
            getRawContent(["custom.jpg"])
        ]
        var renderer = getRenderer(pipelines, rawPageContents)
        let results = try renderer.render(now: Date())

        #expect(results.count == 1)
        switch results[0].source {
        case .asset(_):
            #expect(Bool(false))
        case .content(let value):
            #expect(
                value.contains("http://localhost:3000/assets/slug/custom.png")
            )
        }
    }

    @Test()
    func testAddMore() async throws {
        let pipelines: [Pipeline] = [
            .init(
                id: "test",
                scopes: [:],
                queries: [:],
                dataTypes: .defaults,
                contentTypes: .init(
                    include: ["page"],
                    exclude: [],
                    lastUpdate: [],
                    filterRules: [:]
                ),
                iterators: [:],
                assets: .init(
                    behaviors: [],
                    properties: [
                        .init(
                            action: .add,
                            property: "images",
                            resolvePath: true,
                            input: .init(
                                name: "*",
                                ext: "png"
                            )
                        )
                    ]
                ),
                transformers: [:],
                engine: .init(
                    id: "mustache",
                    options: [
                        "contentTypes": [
                            "page": [
                                "template": "page"
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
        ]
        let rawPageContents: [RawContent] = [
            getRawContent(["custom1.png", "custom2.png"])
        ]
        var renderer = getRenderer(
            pipelines,
            rawPageContents,
            """
            {{#page.images}}
            <img src=\"{{.}}\">
            {{/page.images}}
            """
        )
        let results = try renderer.render(now: Date())

        #expect(results.count == 1)
        switch results[0].source {
        case .asset(_):
            #expect(Bool(false))
        case .content(let value):
            #expect(
                value.contains("http://localhost:3000/assets/slug/custom1.png")
            )
            #expect(
                value.contains("http://localhost:3000/assets/slug/custom2.png")
            )
        }
    }

    @Test()
    func testSetMoreKeys() async throws {
        let pipelines: [Pipeline] = [
            .init(
                id: "test",
                scopes: [:],
                queries: [:],
                dataTypes: .defaults,
                contentTypes: .init(
                    include: ["page"],
                    exclude: [],
                    lastUpdate: [],
                    filterRules: [:]
                ),
                iterators: [:],
                assets: .init(
                    behaviors: [],
                    properties: [
                        .init(
                            action: .set,
                            property: "images",
                            resolvePath: true,
                            input: .init(
                                name: "*",
                                ext: "png"
                            )
                        )
                    ]
                ),
                transformers: [:],
                engine: .init(
                    id: "mustache",
                    options: [
                        "contentTypes": [
                            "page": [
                                "template": "page"
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
        ]
        let rawPageContents: [RawContent] = [
            getRawContent(["custom1.png", "custom2.png"])
        ]
        var renderer = getRenderer(
            pipelines,
            rawPageContents,
            """
            <img src=\"{{page.images.custom1}}\">
            <img src=\"{{page.images.custom2}}\">
            """
        )
        let results = try renderer.render(now: Date())

        #expect(results.count == 1)
        switch results[0].source {
        case .asset(_):
            #expect(Bool(false))
        case .content(let value):
            #expect(
                value.contains("http://localhost:3000/assets/slug/custom1.png")
            )
            #expect(
                value.contains("http://localhost:3000/assets/slug/custom2.png")
            )
        }
    }

    private func getRenderer(
        _ pipelines: [Pipeline],
        _ rawPageContents: [RawContent],
        _ img: String = "<img src=\"{{page.image}}\">"
    ) -> SourceBundleRenderer {

        let logger = Logger(label: "SourceBundleAssetsTestSuite")
        let settings = Settings.defaults
        let config = Config.defaults
        let sourceConfig = SourceConfig(
            sourceUrl: .init(fileURLWithPath: ""),
            config: config
        )

        let pageDefinition = ContentDefinition.Mocks.page()
        let pageContents = rawPageContents.map {
            let converter = ContentDefinitionConverter(
                contentDefinition: pageDefinition,
                dateFormatter: .default,
                logger: logger
            )
            return converter.convert(rawContent: $0)
        }

        let sourceBundle = SourceBundle(
            location: .init(filePath: ""),
            config: config,
            sourceConfig: sourceConfig,
            settings: settings,
            pipelines: pipelines,
            contents: pageContents,
            blockDirectives: [],
            templates: ["page": Templates.Mocks.page(img)],
            baseUrl: "http://localhost:3000/"
        )
        return SourceBundleRenderer(
            sourceBundle: sourceBundle,
            fileManager: FileManager.default,
            logger: logger
        )
    }

    private func getRawContent(_ assets: [String]) -> RawContent {
        .init(
            origin: .init(
                path: "",
                slug: "slug"
            ),
            frontMatter: [
                "title": "Home",
                "description": "Home description",
            ],
            markdown: """
                # Home

                Lorem ipsum dolor sit amet
                """,
            lastModificationDate: Date().timeIntervalSince1970,
            assets: assets
        )
    }

}
