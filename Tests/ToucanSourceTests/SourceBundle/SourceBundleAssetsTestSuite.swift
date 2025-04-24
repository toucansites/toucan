//
//  SourceBundleAssetsTestSuite.swift
//  Toucan
//
//  Created by Viasz-Kádi Ferenc on 2025. 02. 20..
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
    func assets() async throws {
        let logger = Logger(label: "SourceBundleAssetsTestSuite")
        let settings = Settings.defaults
        let config = Config.defaults
        let sourceConfig = SourceConfig(
            sourceUrl: .init(fileURLWithPath: ""),
            config: config
        )
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
                assets: .init(properties: [
                    .init(
                        action: .add,
                        property: "js",
                        resolvePath: false,
                        input: .init(name: "main", ext: "js")
                    )
                ]),
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
                assets: [
                    "main.js"
                ]
            )
        ]
        let pageContents = rawPageContents.map {
            let converter = ContentDefinitionConverter(
                contentDefinition: pageDefinition,
                dateFormatter: .default,
                logger: logger
            )
            return converter.convert(rawContent: $0)
        }

        let contents = pageContents

        let sourceBundle = SourceBundle(
            location: .init(filePath: ""),
            config: config,
            sourceConfig: sourceConfig,
            settings: settings,
            pipelines: pipelines,
            contents: contents,
            blockDirectives: [],
            templates: [:],
            baseUrl: ""
        )

        var renderer = SourceBundleRenderer(
            sourceBundle: sourceBundle,
            fileManager: FileManager.default,
            logger: logger
        )
        let results = try renderer.render(now: Date())

        #expect(results.count == 1)

        print(results)
    }
}
