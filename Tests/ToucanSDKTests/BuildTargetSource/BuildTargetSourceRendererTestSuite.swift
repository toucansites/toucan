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

        _ = try renderer.render(now: now)
    }

    @Test
    func wrongRendererEngine() throws {
        let now = Date()
        let buildTargetSource = BuildTargetSource(
            locations: .init(
                sourceUrl: .init(filePath: ""),
                config: .defaults
            ),
            pipelines: [
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
                    engine: .init(id: "wrong", options: [:]),
                    output: .init(path: "", file: "context", ext: "json")
                )
            ]
        )

        var renderer = BuildTargetSourceRenderer(
            buildTargetSource: buildTargetSource,
            templates: [:],
            generatorInfo: .current
        )

        do {
            _ = try renderer.render(now: now)
        }
        catch let error as BuildTargetSourceRendererError {
            switch error {
            case let .invalidEngine(id):
                #expect(id == "wrong")
            default:
                Issue.record("\(error.logMessage)")
            }
        }
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
    func pipelineContentFilter() async throws {
        let now = Date()

        let pipelines: [Pipeline] = [
            .init(
                id: "test",
                definesType: false,
                scopes: [:],
                queries: [:],
                dataTypes: .defaults,
                contentTypes: .init(
                    include: [
                        "test"
                    ],
                    exclude: [],
                    lastUpdate: [],
                    filterRules: [
                        "*": .field(
                            key: "title",
                            operator: .equals,
                            value: "foo"
                        )
                    ]
                ),
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
                        "type": "test",
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

        let contentDefinitions: [ContentDefinition] = [
            .init(
                id: "test",
                default: true,
                paths: [],
                properties: [
                    "title": .init(
                        propertyType: .string,
                        isRequired: true
                    )
                ],
                relations: [:],
                queries: [:]
            )
        ]

        var buildTargetSource = Mocks.buildTargetSource(now: now)
        buildTargetSource.pipelines = pipelines
        buildTargetSource.rawContents = rawContents
        buildTargetSource.contentDefinitions = contentDefinitions

        var renderer = BuildTargetSourceRenderer(
            buildTargetSource: buildTargetSource,
            templates: [:]
        )
        let results = try renderer.render(now: now)

        #expect(results.isEmpty)
    }

    // MARK: - api

    private func getMockAPIBuildTargetSource(
        now: Date,
        options: [String: AnyCodable]
    ) -> BuildTargetSource {

        let pipelines: [Pipeline] = [
            .init(
                id: "api",
                definesType: true,
                scopes: [:],
                queries: [
                    "posts": .init(
                        contentType: "post",
                        scope: "list",
                        orderBy: [
                            .init(
                                key: "publication",
                                direction: .desc
                            )
                        ]
                    )
                ],
                dataTypes: .defaults,
                contentTypes: .init(
                    include: ["api"],
                    exclude: [],
                    lastUpdate: [],
                    filterRules: [:]
                ),
                iterators: [
                    "api.posts.pagination": .init(
                        contentType: "post",
                        limit: 2
                    )
                ],
                assets: .defaults,
                transformers: [:],
                engine: .init(
                    id: "json",
                    options: options
                ),
                output: .init(
                    path: "",
                    file: "{{slug}}",
                    ext: "json"
                )
            )
        ]

        let rawContents: [RawContent] = [
            .init(
                origin: .init(
                    path: .init("api"),
                    slug: "api"
                ),
                markdown: .init(
                    frontMatter: [
                        "type": "api"
                    ]
                ),
                lastModificationDate: now.timeIntervalSince1970,
                assets: []
            ),
            .init(
                origin: .init(
                    path: .init("api/posts/{{api.posts.pagination}}"),
                    slug: "api/posts/{{api.posts.pagination}}"
                ),
                markdown: .init(
                    frontMatter: [
                        "type": "api"
                    ],
                ),
                lastModificationDate: now.timeIntervalSince1970,
                assets: []
            ),
        ]

        var buildTargetSource = Mocks.buildTargetSource(now: now)
        // keep only api pipeline, exclude sitemap & rss xml contents
        buildTargetSource.pipelines = pipelines
        buildTargetSource.rawContents =
            buildTargetSource.rawContents.filter {
                !$0.origin.path.value.hasSuffix("xml")
                    && !$0.origin.path.value.contains("404")
            } + rawContents

        return buildTargetSource
    }

    @Test()
    func renderAPIBasics() async throws {
        let now = Date()
        let buildTargetSource = getMockAPIBuildTargetSource(
            now: now,
            options: [:]
        )

        var renderer = BuildTargetSourceRenderer(
            buildTargetSource: buildTargetSource,
            templates: [:]
        )
        let results = try renderer.render(now: now)

        #expect(results.count == 3)

        let contents = results.filter { $0.source.isContent }
            .filter { $0.destination.file == "api" }

        #expect(contents.count == 1)

        guard
            case let .content(value) = contents[0].source,
            let data = value.data(using: .utf8)
        else {
            Issue.record("Source type is not a valid content.")
            return
        }

        struct Expected: Decodable {
            struct Item: Decodable {
                let title: String
                let slug: Slug
            }
            struct Context: Decodable {
                let posts: [Item]
            }
            let context: Context
        }

        let decoder = JSONDecoder()
        let result = try decoder.decode(Expected.self, from: data)
        #expect(result.context.posts.count == 3)
    }

    @Test()
    func renderAPIPagination() async throws {
        let now = Date()
        let buildTargetSource = getMockAPIBuildTargetSource(
            now: now,
            options: [:]
        )

        var renderer = BuildTargetSourceRenderer(
            buildTargetSource: buildTargetSource,
            templates: [:]
        )
        let results = try renderer.render(now: now)

        #expect(results.count == 3)

        let contents = results.filter { $0.source.isContent }
            .filter { $0.destination.file != "api" }

        #expect(contents.count == 2)

        for content in contents {
            guard
                case let .content(value) = content.source,
                let data = value.data(using: .utf8)
            else {
                Issue.record("Source type is not a valid content.")
                return
            }

            struct Expected: Decodable {
                struct Item: Decodable {
                    let title: String
                    let slug: Slug
                }
                struct Iterator: Decodable {
                    let current: Int
                    let items: [Item]
                }
                let iterator: Iterator
            }

            let decoder = JSONDecoder()

            let result = try decoder.decode(Expected.self, from: data)
            switch result.iterator.current {
            case 1:
                #expect(result.iterator.items.count == 2)
            case 2:
                #expect(result.iterator.items.count == 1)
            default:
                Issue.record("Invalid iterator page.")
            }
        }
    }

    @Test()
    func renderAPIWithEngineOptionsKeyPath() async throws {
        let now = Date()
        let buildTargetSource = getMockAPIBuildTargetSource(
            now: now,
            options: [
                "keyPath": "context.posts"
            ]
        )

        var renderer = BuildTargetSourceRenderer(
            buildTargetSource: buildTargetSource,
            templates: [:]
        )
        let results = try renderer.render(now: now)

        #expect(results.count == 3)

        let contents = results.filter { $0.source.isContent }
            .filter { $0.destination.file == "api" }

        #expect(contents.count == 1)

        guard
            case let .content(value) = contents[0].source,
            let data = value.data(using: .utf8)
        else {
            Issue.record("Source type is not a valid content.")
            return
        }

        struct Expected: Decodable {
            let title: String
            let slug: Slug
        }

        let decoder = JSONDecoder()
        let result = try decoder.decode([Expected].self, from: data)
        #expect(result.count == 3)
    }

    @Test()
    func renderAPIWithEngineOptionsMultipleKeyPaths() async throws {
        let now = Date()
        let buildTargetSource = getMockAPIBuildTargetSource(
            now: now,
            options: [
                "keyPaths": [
                    "context.posts": "items",
                    "generator": "info",
                ]
            ]
        )

        var renderer = BuildTargetSourceRenderer(
            buildTargetSource: buildTargetSource,
            templates: [:]
        )
        let results = try renderer.render(now: now)

        let contents = results.filter { $0.source.isContent }
            .filter { $0.destination.file == "api" }

        #expect(contents.count == 1)

        guard
            case let .content(value) = contents[0].source,
            let data = value.data(using: .utf8)
        else {
            Issue.record("Source type is not a valid content.")
            return
        }

        struct Expected: Decodable {
            struct Item: Decodable {
                let title: String
                let slug: Slug
            }
            struct Info: Decodable {
                let name: String
                let version: String
            }
            let items: [Item]
            let info: Info
        }

        let decoder = JSONDecoder()
        let result = try decoder.decode(Expected.self, from: data)

        #expect(result.items.count == 3)
        #expect(result.info.name == "Toucan")

    }

    // MARK: - contents

    @Test()
    func renderAuthor() async throws {
        let now = Date()

        var buildTargetSource = Mocks.buildTargetSource(now: now)
        // keep only html pipeline & one author
        buildTargetSource.pipelines = buildTargetSource.pipelines.filter {
            $0.id == "html"
        }
        buildTargetSource.rawContents = buildTargetSource.rawContents.filter {
            $0.origin.slug == "blog/authors/author-1"
        }

        var renderer = BuildTargetSourceRenderer(
            buildTargetSource: buildTargetSource,
            templates: Mocks.Views.all()
        )
        let results = try renderer.render(now: now)

        #expect(results.count == 2)

        let contents = results.filter { $0.source.isContent }
        #expect(contents.count == 1)

        let assets = results.filter { $0.source.isAsset }
        #expect(assets.count == 1)

        guard case let .content(value) = contents[0].source else {
            Issue.record("Source type is not a valid content.")
            return
        }
        #expect(!value.contains("./assets"))

        guard case let .assetFile(path) = assets[0].source else {
            Issue.record("Source type is not a valid asset file.")
            return
        }
        #expect(path == "blog/authors/author-1/assets/author-1.jpg")
    }

    // MARK: - assets

    @Test()
    func assetPropertyAddOne() async throws {
        let now = Date()

        let pipelines: [Pipeline] = [
            .init(
                id: "test",
                definesType: true,
                scopes: [:],
                queries: [:],
                dataTypes: .defaults,
                contentTypes: .defaults,
                iterators: [:],
                assets: .init(
                    behaviors: [],
                    properties: [
                        .init(
                            action: .add,
                            property: "css",
                            resolvePath: true,
                            input: .init(
                                path: nil,
                                name: "style",
                                ext: "css"
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
                output: .init(path: "", file: "context", ext: "json")
            )
        ]

        let rawContents: [RawContent] = [
            .init(
                origin: .init(
                    path: .init("test"),
                    slug: "test"
                ),
                markdown: .init(
                    frontMatter: [
                        "type": "test",
                        "css": [
                            "https://test.css"
                        ],
                    ]
                ),
                lastModificationDate: now.timeIntervalSince1970,
                assets: [
                    "style.css"
                ]
            )
        ]

        let contentDefinitions: [ContentDefinition] = []

        var buildTargetSource = Mocks.buildTargetSource(now: now)
        buildTargetSource.pipelines = pipelines
        buildTargetSource.rawContents = rawContents
        buildTargetSource.contentDefinitions = contentDefinitions

        var renderer = BuildTargetSourceRenderer(
            buildTargetSource: buildTargetSource,
            templates: [:]
        )
        let results = try renderer.render(now: now)

        #expect(results.count == 1)

        let contents = results.filter { $0.source.isContent }
        #expect(contents.count == 1)

        guard case let .content(value) = contents[0].source else {
            Issue.record("Source type is not a valid content.")
            return
        }

        let decoder = JSONDecoder()

        struct Exp: Decodable {
            let css: [String]
        }

        let data = try #require(value.data(using: .utf8))
        let exp = try decoder.decode(Exp.self, from: data)

        #expect(
            exp.css.sorted()
                == [
                    "https://test.css",
                    "http://localhost:3000/assets/test/style.css",
                ]
                .sorted()
        )
    }

    @Test()
    func assetPropertyAddMultiple() async throws {
        let now = Date()

        let pipelines: [Pipeline] = [
            .init(
                id: "test",
                definesType: true,
                scopes: [:],
                queries: [:],
                dataTypes: .defaults,
                contentTypes: .defaults,
                iterators: [:],
                assets: .init(
                    behaviors: [],
                    properties: [
                        .init(
                            action: .add,
                            property: "css",
                            resolvePath: false,
                            input: .init(
                                path: nil,
                                name: "*",
                                ext: "css"
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
                output: .init(path: "", file: "context", ext: "json")
            )
        ]

        let rawContents: [RawContent] = [
            .init(
                origin: .init(
                    path: .init("test"),
                    slug: "test"
                ),
                markdown: .init(
                    frontMatter: [
                        "type": "test",
                        "css": [
                            "https://test.css"
                        ],
                    ]
                ),
                lastModificationDate: now.timeIntervalSince1970,
                assets: [
                    "foo.css",
                    "bar.css",
                ]
            )
        ]

        let contentDefinitions: [ContentDefinition] = []

        var buildTargetSource = Mocks.buildTargetSource(now: now)
        buildTargetSource.pipelines = pipelines
        buildTargetSource.rawContents = rawContents
        buildTargetSource.contentDefinitions = contentDefinitions

        var renderer = BuildTargetSourceRenderer(
            buildTargetSource: buildTargetSource,
            templates: [:]
        )
        let results = try renderer.render(now: now)

        #expect(results.count == 1)

        let contents = results.filter { $0.source.isContent }
        #expect(contents.count == 1)

        guard case let .content(value) = contents[0].source else {
            Issue.record("Source type is not a valid content.")
            return
        }

        let decoder = JSONDecoder()

        struct Exp: Decodable {
            let css: [String]
        }

        let data = try #require(value.data(using: .utf8))
        let exp = try decoder.decode(Exp.self, from: data)

        #expect(
            exp.css.sorted()
                == [
                    "https://test.css",
                    "foo.css",
                    "bar.css",
                ]
                .sorted()
        )
    }

    @Test()
    func assetPropertySetOne() async throws {
        let now = Date()

        let pipelines: [Pipeline] = [
            .init(
                id: "test",
                definesType: true,
                scopes: [:],
                queries: [:],
                dataTypes: .defaults,
                contentTypes: .defaults,
                iterators: [:],
                assets: .init(
                    behaviors: [],
                    properties: [
                        .init(
                            action: .set,
                            property: "image",
                            resolvePath: true,
                            input: .init(
                                path: nil,
                                name: "cover",
                                ext: "jpg"
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
                output: .init(path: "", file: "context", ext: "json")
            )
        ]

        let rawContents: [RawContent] = [
            .init(
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
                    "cover.jpg"
                ]
            )
        ]

        let contentDefinitions: [ContentDefinition] = []

        var buildTargetSource = Mocks.buildTargetSource(now: now)
        buildTargetSource.pipelines = pipelines
        buildTargetSource.rawContents = rawContents
        buildTargetSource.contentDefinitions = contentDefinitions

        var renderer = BuildTargetSourceRenderer(
            buildTargetSource: buildTargetSource,
            templates: [:]
        )
        let results = try renderer.render(now: now)

        #expect(results.count == 1)

        let contents = results.filter { $0.source.isContent }
        #expect(contents.count == 1)

        guard case let .content(value) = contents[0].source else {
            Issue.record("Source type is not a valid content.")
            return
        }

        let decoder = JSONDecoder()

        struct Exp: Decodable {
            let image: String
        }

        let data = try #require(value.data(using: .utf8))
        let exp = try decoder.decode(Exp.self, from: data)

        #expect(exp.image == "http://localhost:3000/assets/test/cover.jpg")
    }

    @Test()
    func assetPropertySetMultiple() async throws {
        let now = Date()

        let pipelines: [Pipeline] = [
            .init(
                id: "test",
                definesType: true,
                scopes: [:],
                queries: [:],
                dataTypes: .defaults,
                contentTypes: .defaults,
                iterators: [:],
                assets: .init(
                    behaviors: [],
                    properties: [
                        .init(
                            action: .set,
                            property: "images",
                            resolvePath: true,
                            input: .init(
                                path: nil,
                                name: "*",
                                ext: "png"
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
                output: .init(path: "", file: "context", ext: "json")
            )
        ]

        let rawContents: [RawContent] = [
            .init(
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
                    "foo.png",
                    "bar.png",
                ]
            )
        ]

        let contentDefinitions: [ContentDefinition] = []

        var buildTargetSource = Mocks.buildTargetSource(now: now)
        buildTargetSource.pipelines = pipelines
        buildTargetSource.rawContents = rawContents
        buildTargetSource.contentDefinitions = contentDefinitions

        var renderer = BuildTargetSourceRenderer(
            buildTargetSource: buildTargetSource,
            templates: [:]
        )
        let results = try renderer.render(now: now)

        #expect(results.count == 1)

        let contents = results.filter { $0.source.isContent }
        #expect(contents.count == 1)

        guard case let .content(value) = contents[0].source else {
            Issue.record("Source type is not a valid content.")
            return
        }

        let decoder = JSONDecoder()

        struct Exp: Decodable {
            let images: [String: String]
        }

        let data = try #require(value.data(using: .utf8))
        let exp = try decoder.decode(Exp.self, from: data)

        #expect(exp.images.keys.sorted() == ["foo", "bar"].sorted())
        #expect(
            exp.images.values.sorted()
                == [
                    "http://localhost:3000/assets/test/foo.png",
                    "http://localhost:3000/assets/test/bar.png",
                ]
                .sorted()
        )
    }

}
