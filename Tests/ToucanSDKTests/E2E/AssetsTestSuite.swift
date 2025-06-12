//
//  AssetsTestSuite.swift
//  Toucan
//
//  Created by gerp83 on 2025. 04. 24..
//
//

import Foundation
import Testing
import Logging
import ToucanCore
import ToucanSource
import FileManagerKitBuilder
@testable import ToucanSDK

@Suite
struct AssetsTestSuite {

    @Test
    func test404HTMLPage() throws {
        let now = Date()

        try FileManagerPlayground {
            Mocks.E2E.src(
                now: now
            )
        }
        .test {
            let input = $1.appendingPathIfPresent("src")
            try Toucan(input: input.path()).generate()

            let output = $1.appendingPathIfPresent("docs")
            let notFoundUrl = output.appendingPathIfPresent("404.html")
            let notFound = try String(contentsOf: notFoundUrl)

            #expect(notFound.contains("Not found page contents"))

        }
    }

    //
    //    @Test()
    //    func testSet() async throws {
    //        let pipelines: [Pipeline] = [
    //            .init(
    //                id: "test",
    //                scopes: [:],
    //                queries: [:],
    //                dataTypes: .defaults,
    //                contentTypes: .init(
    //                    include: ["page"],
    //                    exclude: [],
    //                    lastUpdate: [],
    //                    filterRules: [:]
    //                ),
    //                iterators: [:],
    //                assets: .init(
    //                    behaviors: [],
    //                    properties: [
    //                        .init(
    //                            action: .set,
    //                            property: "image",
    //                            resolvePath: true,
    //                            input: .init(
    //                                name: "cover",
    //                                ext: "jpg"
    //                            )
    //                        )
    //                    ]
    //                ),
    //                transformers: [:],
    //                engine: .init(
    //                    id: "mustache",
    //                    options: [
    //                        "contentTypes": [
    //                            "page": [
    //                                "template": "page"
    //                            ]
    //                        ]
    //                    ]
    //                ),
    //                output: .init(
    //                    path: "{{slug}}",
    //                    file: "index",
    //                    ext: "html"
    //                )
    //            )
    //        ]
    //        let rawPageContents: [RawContent] = [
    //            getRawContent(["cover.jpg"])
    //        ]
    //        var renderer = getRenderer(pipelines, rawPageContents)
    //        let results = try renderer.render(now: Date())
    //            .filter(\.source.isContent)
    //
    //        #expect(results.count == 1)
    //
    //        switch results[0].source {
    //        case .assetFile(_), .asset(_):
    //            #expect(Bool(false))
    //        case .content(let value):
    //            #expect(
    //                value.contains("http://localhost:3000/assets/slug/cover.jpg")
    //            )
    //        }
    //    }
    //
    //    @Test()
    //    func testSetMore() async throws {
    //        let pipelines: [Pipeline] = [
    //            .init(
    //                id: "test",
    //                scopes: [:],
    //                queries: [:],
    //                dataTypes: .defaults,
    //                contentTypes: .init(
    //                    include: ["page"],
    //                    exclude: [],
    //                    lastUpdate: [],
    //                    filterRules: [:]
    //                ),
    //                iterators: [:],
    //                assets: .init(
    //                    behaviors: [],
    //                    properties: [
    //                        .init(
    //                            action: .set,
    //                            property: "image",
    //                            resolvePath: true,
    //                            input: .init(name: "*", ext: "png")
    //                        )
    //                    ]
    //                ),
    //                transformers: [:],
    //                engine: .init(
    //                    id: "mustache",
    //                    options: [
    //                        "contentTypes": [
    //                            "page": [
    //                                "template": "page"
    //                            ]
    //                        ]
    //                    ]
    //                ),
    //                output: .init(
    //                    path: "{{slug}}",
    //                    file: "index",
    //                    ext: "html"
    //                )
    //            )
    //        ]
    //        let rawPageContents: [RawContent] = [
    //            getRawContent(["custom1.png", "custom2.png"])
    //        ]
    //        var renderer = getRenderer(
    //            pipelines,
    //            rawPageContents,
    //            """
    //            <img src=\"{{page.image.custom1}}\">
    //            <img src=\"{{page.image.custom2}}\">
    //            """
    //        )
    //        let results = try renderer.render(now: Date())
    //            .filter(\.source.isContent)
    //
    //        #expect(results.count == 1)
    //        switch results[0].source {
    //        case .assetFile(_), .asset(_):
    //            #expect(Bool(false))
    //        case .content(let value):
    //            #expect(
    //                value.contains("http://localhost:3000/assets/slug/custom1.png")
    //            )
    //            #expect(
    //                value.contains("http://localhost:3000/assets/slug/custom2.png")
    //            )
    //        }
    //    }
    //
    //    @Test()
    //    func testAdd() async throws {
    //        let pipelines: [Pipeline] = [
    //            .init(
    //                id: "test",
    //                scopes: [:],
    //                queries: [:],
    //                dataTypes: .defaults,
    //                contentTypes: .init(
    //                    include: ["page"],
    //                    exclude: [],
    //                    lastUpdate: [],
    //                    filterRules: [:]
    //                ),
    //                iterators: [:],
    //                assets: .init(
    //                    behaviors: [],
    //                    properties: [
    //                        .init(
    //                            action: .add,
    //                            property: "images",
    //                            resolvePath: true,
    //                            input: .init(name: "custom", ext: "jpg")
    //                        )
    //                    ]
    //                ),
    //                transformers: [:],
    //                engine: .init(
    //                    id: "mustache",
    //                    options: [
    //                        "contentTypes": [
    //                            "page": [
    //                                "template": "page"
    //                            ]
    //                        ]
    //                    ]
    //                ),
    //                output: .init(
    //                    path: "{{slug}}",
    //                    file: "index",
    //                    ext: "html"
    //                )
    //            )
    //        ]
    //        let rawPageContents: [RawContent] = [
    //            getRawContent(["custom.jpg"])
    //        ]
    //
    //        var renderer = getRenderer(
    //            pipelines,
    //            rawPageContents,
    //            "<img src=\"{{#page.images}}{{.}}{{/page.images}}\">"
    //        )
    //        let results = try renderer.render(now: Date())
    //            .filter(\.source.isContent)
    //
    //        #expect(results.count == 1)
    //        switch results[0].source {
    //        case .assetFile(_), .asset(_):
    //            #expect(Bool(false))
    //        case .content(let value):
    //            #expect(
    //                value.contains("http://localhost:3000/assets/slug/custom.jpg")
    //            )
    //        }
    //    }
    //
    //    @Test()
    //    func testAddMore() async throws {
    //        let pipelines: [Pipeline] = [
    //            .init(
    //                id: "test",
    //                scopes: [:],
    //                queries: [:],
    //                dataTypes: .defaults,
    //                contentTypes: .init(
    //                    include: ["page"],
    //                    exclude: [],
    //                    lastUpdate: [],
    //                    filterRules: [:]
    //                ),
    //                iterators: [:],
    //                assets: .init(
    //                    behaviors: [],
    //                    properties: [
    //                        .init(
    //                            action: .add,
    //                            property: "images",
    //                            resolvePath: true,
    //                            input: .init(
    //                                name: "*",
    //                                ext: "png"
    //                            )
    //                        )
    //                    ]
    //                ),
    //                transformers: [:],
    //                engine: .init(
    //                    id: "mustache",
    //                    options: [
    //                        "contentTypes": [
    //                            "page": [
    //                                "template": "page"
    //                            ]
    //                        ]
    //                    ]
    //                ),
    //                output: .init(
    //                    path: "{{slug}}",
    //                    file: "index",
    //                    ext: "html"
    //                )
    //            )
    //        ]
    //        let rawPageContents: [RawContent] = [
    //            getRawContent(["custom1.png", "custom2.png"])
    //        ]
    //        var renderer = getRenderer(
    //            pipelines,
    //            rawPageContents,
    //            """
    //            {{#page.images}}
    //            <img src=\"{{.}}\">
    //            {{/page.images}}
    //            """
    //        )
    //        let results = try renderer.render(now: Date())
    //            .filter(\.source.isContent)
    //
    //        #expect(results.count == 1)
    //        switch results[0].source {
    //        case .assetFile(_), .asset(_):
    //            #expect(Bool(false))
    //        case .content(let value):
    //            #expect(
    //                value.contains("http://localhost:3000/assets/slug/custom1.png")
    //            )
    //            #expect(
    //                value.contains("http://localhost:3000/assets/slug/custom2.png")
    //            )
    //        }
    //    }
    //
    //    @Test()
    //    func testSetMoreKeys() async throws {
    //        let pipelines: [Pipeline] = [
    //            .init(
    //                id: "test",
    //                scopes: [:],
    //                queries: [:],
    //                dataTypes: .defaults,
    //                contentTypes: .init(
    //                    include: ["page"],
    //                    exclude: [],
    //                    lastUpdate: [],
    //                    filterRules: [:]
    //                ),
    //                iterators: [:],
    //                assets: .init(
    //                    behaviors: [],
    //                    properties: [
    //                        .init(
    //                            action: .set,
    //                            property: "images",
    //                            resolvePath: true,
    //                            input: .init(
    //                                name: "*",
    //                                ext: "png"
    //                            )
    //                        )
    //                    ]
    //                ),
    //                transformers: [:],
    //                engine: .init(
    //                    id: "mustache",
    //                    options: [
    //                        "contentTypes": [
    //                            "page": [
    //                                "template": "page"
    //                            ]
    //                        ]
    //                    ]
    //                ),
    //                output: .init(
    //                    path: "{{slug}}",
    //                    file: "index",
    //                    ext: "html"
    //                )
    //            )
    //        ]
    //        let rawPageContents: [RawContent] = [
    //            getRawContent(["custom1.png", "custom2.png"])
    //        ]
    //        var renderer = getRenderer(
    //            pipelines,
    //            rawPageContents,
    //            """
    //            <img src=\"{{page.images.custom1}}\">
    //            <img src=\"{{page.images.custom2}}\">
    //            """
    //        )
    //        let results = try renderer.render(now: Date())
    //            .filter(\.source.isContent)
    //
    //        #expect(results.count == 1)
    //        switch results[0].source {
    //        case .assetFile(_), .asset(_):
    //            #expect(Bool(false))
    //        case .content(let value):
    //            #expect(
    //                value.contains("http://localhost:3000/assets/slug/custom1.png")
    //            )
    //            #expect(
    //                value.contains("http://localhost:3000/assets/slug/custom2.png")
    //            )
    //        }
    //    }
    //
    //    private func getRenderer(
    //        _ pipelines: [Pipeline],
    //        _ rawPageContents: [RawContent],
    //        _ img: String = "<img src=\"{{page.image}}\">"
    //    ) -> BuildTargetSourceRenderer {
    //
    //        let logger = Logger(label: "BuildTargetSourceAssetsTestSuite")
    //        let target = Target.standard
    //        let config = Config.defaults
    //        let sourceConfig = SourceLocations(
    //            sourceUrl: .init(fileURLWithPath: ""),
    //            config: config
    //        )
    //
    //        let pageDefinition = ContentDefinition.Mocks.page()
    //        let pageContents = rawPageContents.map {
    //            let converter = ContentDefinitionConverter(
    //                contentDefinition: pageDefinition,
    //                dateFormatter: .default,
    //                logger: logger
    //            )
    //            return converter.convert(rawContent: $0)
    //        }
    //
    //        let buildTargetSource = BuildTargetSource(
    //            location: .init(filePath: ""),
    //            target: target,
    //            config: config,
    //            sourceConfig: sourceConfig,
    //            settings: .standard,
    //            pipelines: pipelines,
    //            contents: pageContents,
    //            blockDirectives: [],
    //            templates: ["page": Templates.Mocks.page(img)],
    //            baseUrl: "http://localhost:3000/"
    //        )
    //        return BuildTargetSourceRenderer(
    //            buildTargetSource: buildTargetSource,
    //            fileManager: FileManager.default,
    //            logger: logger
    //        )
    //    }

    //
    //    @Test
    //    func testLoadSvg() async throws {
    //        let logger = Logger(label: "ToucanTestSuite")
    //        try FileManagerPlayground {
    //            Directory(name: "src") {
    //                Directory(name: "contents") {
    //                    Directory(name: "page1") {
    //                        File(
    //                            name: "index.yaml",
    //                            string: """
    //                                title: title
    //                                type: page
    //                                description: Desc1
    //                                label: label1
    //                                """
    //                        )
    //                        Directory(name: "assets") {
    //                            svg1()
    //                        }
    //                    }
    //                }
    //                Directory(name: "pipelines") {
    //                    File(
    //                        name: "html.yml",
    //                        string: """
    //                            id: html
    //
    //                            contentTypes:
    //                                include:
    //                                    - page
    //                            engine:
    //                                id: mustache
    //                                options:
    //                                    contentTypes:
    //                                        page:
    //                                            template: "pages.default"
    //                            assets:
    //                              behaviors:
    //                                - id: copy
    //                              properties:
    //                                - action: load
    //                                  property: svg
    //                                  resolvePath: false
    //                                  input:
    //                                    name: "test1"
    //                                    ext: svg
    //
    //                            output:
    //                                path: "{{slug}}"
    //                                file: index
    //                                ext: html
    //                            """
    //                    )
    //                }
    //                Directory(name: "types") {
    //                    typePage()
    //                }
    //                Directory(name: "themes") {
    //                    Directory(name: "default") {
    //                        Directory(name: "templates") {
    //                            Directory(name: "pages") {
    //                                themeDefaultMustache(svg: "{{page.svg}}")
    //                            }
    //                            themeHtmlMustache()
    //                        }
    //                    }
    //                }
    //                configFile()
    //            }
    //        }
    //        .test {
    //            let input = $1.appending(path: "src/")
    //            let output = $1.appending(path: "docs/")
    //            try getToucan(input, output, logger).generate()
    //
    //            let svgPath = output.appending(path: "assets/page1/test1.svg")
    //            #expect($0.fileExists(at: svgPath))
    //
    //            let htmlPath = output.appending(path: "page1/index.html")
    //            #expect($0.fileExists(at: htmlPath))
    //
    //            let contents = try htmlPath.loadContents()
    //            #expect(contents.contains("/svg"))
    //        }
    //    }
    //
    //    @Test
    //    func testLoadMoreSvg() async throws {
    //        let logger = Logger(label: "ToucanTestSuite")
    //        try FileManagerPlayground {
    //            Directory(name: "src") {
    //                Directory(name: "contents") {
    //                    Directory(name: "page1") {
    //                        File(
    //                            name: "index.yaml",
    //                            string: """
    //                                title: title
    //                                type: page
    //                                description: Desc1
    //                                label: label1
    //                                """
    //                        )
    //                        Directory(name: "assets") {
    //                            svg1()
    //                            svg2()
    //                        }
    //                    }
    //                }
    //                Directory(name: "pipelines") {
    //                    File(
    //                        name: "html.yml",
    //                        string: """
    //                            id: html
    //                            contentTypes:
    //                                include:
    //                                    - page
    //                            engine:
    //                                id: mustache
    //                                options:
    //                                    contentTypes:
    //                                        page:
    //                                            template: "pages.default"
    //                            assets:
    //                              behaviors:
    //                                - id: copy
    //                              properties:
    //                                - action: load
    //                                  property: svg
    //                                  resolvePath: false
    //                                  input:
    //                                    name: "*"
    //                                    ext: svg
    //
    //                            output:
    //                                path: "{{slug}}"
    //                                file: index
    //                                ext: html
    //                            """
    //                    )
    //                }
    //                Directory(name: "types") {
    //                    typePage()
    //                }
    //                Directory(name: "themes") {
    //                    Directory(name: "default") {
    //                        Directory(name: "templates") {
    //                            Directory(name: "pages") {
    //                                themeDefaultMustache(
    //                                    svg: """
    //                                            {{page.svg.test1}}
    //                                            {{page.svg.test2}}
    //                                        """
    //                                )
    //                            }
    //                            themeHtmlMustache()
    //                        }
    //                    }
    //                }
    //                configFile()
    //            }
    //        }
    //        .test {
    //            let input = $1.appending(path: "src/")
    //            let output = $1.appending(path: "docs/")
    //            try getToucan(input, output, logger).generate()
    //
    //            let svgPath = output.appending(path: "assets/page1/test1.svg")
    //            #expect($0.fileExists(at: svgPath))
    //
    //            let svgPath2 = output.appending(path: "assets/page1/test1.svg")
    //            #expect($0.fileExists(at: svgPath2))
    //
    //            let htmlPath = output.appending(path: "page1/index.html")
    //            #expect($0.fileExists(at: htmlPath))
    //
    //            let contents = try htmlPath.loadContents()
    //            #expect(contents.contains("/svg"))
    //        }
    //    }
    //
    //    @Test
    //    func testParse() async throws {
    //        let logger = Logger(label: "ToucanTestSuite")
    //        try FileManagerPlayground {
    //            Directory(name: "src") {
    //                Directory(name: "contents") {
    //                    Directory(name: "page1") {
    //                        File(
    //                            name: "index.yaml",
    //                            string: """
    //                                title: title
    //                                type: page
    //                                description: Desc1
    //                                label: label1
    //                                """
    //                        )
    //                        Directory(name: "assets") {
    //                            yaml1()
    //                        }
    //                    }
    //                }
    //                Directory(name: "pipelines") {
    //                    File(
    //                        name: "html.yml",
    //                        string: """
    //                            id: html
    //                            contentTypes:
    //                                include:
    //                                    - page
    //                            engine:
    //                                id: mustache
    //                                options:
    //                                    contentTypes:
    //                                        page:
    //                                            template: "pages.default"
    //                            assets:
    //                              behaviors:
    //                                - id: copy
    //                              properties:
    //                                - action: parse
    //                                  property: yaml
    //                                  resolvePath: false
    //                                  input:
    //                                    name: "test1"
    //                                    ext: yaml
    //
    //                            output:
    //                                path: "{{slug}}"
    //                                file: index
    //                                ext: html
    //                            """
    //                    )
    //                }
    //                Directory(name: "types") {
    //                    typePage()
    //                }
    //                Directory(name: "themes") {
    //                    Directory(name: "default") {
    //                        Directory(name: "templates") {
    //                            Directory(name: "pages") {
    //                                themeDefaultMustache(
    //                                    yaml:
    //                                        """
    //                                        {{page.yaml.key1}}
    //                                        {{page.yaml.key2}}
    //                                        """
    //                                )
    //                            }
    //                            themeHtmlMustache()
    //                        }
    //                    }
    //                }
    //                configFile()
    //            }
    //        }
    //        .test {
    //            let input = $1.appending(path: "src/")
    //            let output = $1.appending(path: "docs/")
    //            try getToucan(input, output, logger).generate()
    //
    //            let svgPath = output.appending(path: "assets/page1/test1.yaml")
    //            #expect($0.fileExists(at: svgPath))
    //
    //            let htmlPath = output.appending(path: "page1/index.html")
    //            #expect($0.fileExists(at: htmlPath))
    //
    //            let contents = try htmlPath.loadContents()
    //            #expect(contents.contains("value1"))
    //            #expect(contents.contains("value2"))
    //        }
    //    }
    //
    //    @Test
    //    func testParseMore() async throws {
    //        let logger = Logger(label: "ToucanTestSuite")
    //        try FileManagerPlayground {
    //            Directory(name: "src") {
    //                Directory(name: "contents") {
    //                    Directory(name: "page1") {
    //                        File(
    //                            name: "index.yaml",
    //                            string: """
    //                                title: title
    //                                type: page
    //                                description: Desc1
    //                                label: label1
    //                                """
    //                        )
    //                        Directory(name: "assets") {
    //                            yaml1()
    //                            yaml2()
    //                        }
    //                    }
    //                }
    //                Directory(name: "pipelines") {
    //                    File(
    //                        name: "html.yml",
    //                        string: """
    //                            id: html
    //                            contentTypes:
    //                                include:
    //                                    - page
    //                            engine:
    //                                id: mustache
    //                                options:
    //                                    contentTypes:
    //                                        page:
    //                                            template: "pages.default"
    //                            assets:
    //                              behaviors:
    //                                - id: copy
    //                              properties:
    //                                - action: parse
    //                                  property: yaml
    //                                  resolvePath: false
    //                                  input:
    //                                    name: "*"
    //                                    ext: yaml
    //
    //                            output:
    //                                path: "{{slug}}"
    //                                file: index
    //                                ext: html
    //                            """
    //                    )
    //                }
    //                Directory(name: "types") {
    //                    typePage()
    //                }
    //                Directory(name: "themes") {
    //                    Directory(name: "default") {
    //                        Directory(name: "templates") {
    //                            Directory(name: "pages") {
    //                                themeDefaultMustache(
    //                                    yaml:
    //                                        """
    //                                        {{page.yaml.test1.key1}}
    //                                        {{page.yaml.test1.key2}}
    //                                        {{page.yaml.test2.key3}}
    //                                        {{page.yaml.test2.key4}}
    //                                        """
    //                                )
    //                            }
    //                            themeHtmlMustache()
    //                        }
    //                    }
    //                }
    //                configFile()
    //            }
    //        }
    //        .test {
    //            let input = $1.appending(path: "src/")
    //            let output = $1.appending(path: "docs/")
    //            try getToucan(input, output, logger).generate()
    //
    //            let svgPath = output.appending(path: "assets/page1/test1.yaml")
    //            #expect($0.fileExists(at: svgPath))
    //
    //            let htmlPath = output.appending(path: "page1/index.html")
    //            #expect($0.fileExists(at: htmlPath))
    //
    //            let contents = try htmlPath.loadContents()
    //            #expect(contents.contains("value1"))
    //            #expect(contents.contains("value2"))
    //            #expect(contents.contains("value3"))
    //            #expect(contents.contains("value4"))
    //        }
    //    }
    //
    //
    //    // MARK: - behaviors
    //
    //
    //    @Test
    //    func testMinifyCSSAsset() async throws {
    //        let logger = Logger(label: "ToucanTestSuite")
    //        try FileManagerPlayground {
    //            Directory(name: "src") {
    //                Directory(name: "contents") {
    //                    Directory(name: "page1") {
    //                        File(
    //                            name: "index.yaml",
    //                            string: """
    //                                title: title
    //                                type: page
    //                                description: Desc1
    //                                label: label1
    //                                """
    //                        )
    //                        Directory(name: "assets") {
    //                            File(
    //                                name: "style.css",
    //                                string: """
    //                                    html {
    //                                        margin: 0;
    //                                        padding: 0;
    //                                    }
    //                                    body {
    //                                        background: red;
    //                                    }
    //                                    """
    //                            )
    //                        }
    //                    }
    //                }
    //                Directory(name: "pipelines") {
    //                    YAML(
    //                        name: "html",
    //                        contents: Mocks.Pipelines.html()
    //                    )
    //                }
    //                Directory(name: "types") {
    //                    YAML(
    //                        name: "page",
    //                        contents: Mocks.ContentDefinitions.page()
    //                    )
    //                }
    //                Directory(name: "themes") {
    //                    Directory(name: "default") {
    //                        Directory(name: "templates") {
    //                            Directory(name: "pages") {
    //                                themeDefaultMustache(svg: "{{page.svg}}")
    //                            }
    //                            themeHtmlMustache()
    //                        }
    //                    }
    //                }
    //                configFile()
    //            }
    //        }
    //        .test {
    //            let input = $1.appending(path: "src/")
    //            let output = $1.appending(path: "docs/")
    //            try getToucan(input, output, logger).generate()
    //
    //            let cssPath = output.appending(path: "assets/page1/style.min.css")
    //            #expect($0.fileExists(at: cssPath))
    //
    //            let contents = try cssPath.loadContents()
    //            #expect(
    //                contents.contains(
    //                    "html{margin:0;padding:0}body{background:red}"
    //                )
    //            )
    //        }
    //    }
    //
    //    @Test
    //    func testSASSAsset() async throws {
    //        let logger = Logger(label: "ToucanTestSuite")
    //        try FileManagerPlayground {
    //            Directory(name: "src") {
    //                Directory(name: "contents") {
    //                    Directory(name: "page1") {
    //                        File(
    //                            name: "index.yaml",
    //                            string: """
    //                                title: title
    //                                type: page
    //                                description: Desc1
    //                                label: label1
    //                                """
    //                        )
    //                        Directory(name: "assets") {
    //                            File(
    //                                name: "style.sass",
    //                                string: """
    //                                    $font-stack: Helvetica, sans-serif
    //                                    $primary-color: #333
    //
    //                                    body
    //                                      font: 100% $font-stack
    //                                      color: $primary-color
    //                                    """
    //                            )
    //                        }
    //                    }
    //                }
    //                Directory(name: "pipelines") {
    //                    File(
    //                        name: "html.yml",
    //                        string: """
    //                            id: html
    //                            assets:
    //                                behaviors:
    //                                    - id: compile-sass
    //                                      input:
    //                                        name: "style"
    //                                        ext: "sass"
    //                                      output:
    //                                        name: "style.min"
    //                                        ext: "css"
    //
    //                            contentTypes:
    //                                include:
    //                                    - page
    //                            engine:
    //                                id: mustache
    //                                options:
    //                                    contentTypes:
    //                                        page:
    //                                            template: "pages.default"
    //                            output:
    //                                path: "{{slug}}"
    //                                file: index
    //                                ext: html
    //                            """
    //                    )
    //                }
    //                Directory(name: "types") {
    //                    typePage()
    //                }
    //                Directory(name: "themes") {
    //                    Directory(name: "default") {
    //                        Directory(name: "templates") {
    //                            Directory(name: "pages") {
    //                                themeDefaultMustache(svg: "{{page.svg}}")
    //                            }
    //                            themeHtmlMustache()
    //                        }
    //                    }
    //                }
    //                configFile()
    //            }
    //        }
    //        .test {
    //            let input = $1.appending(path: "src/")
    //            let output = $1.appending(path: "docs/")
    //            try getToucan(input, output, logger).generate()
    //
    //            let assetsPath = output.appending(path: "assets/page1/")
    //
    //            #expect($0.listDirectory(at: assetsPath).count == 1)
    //
    //            let cssPath = assetsPath.appending(path: "style.min.css")
    //            #expect($0.fileExists(at: cssPath))
    //
    //            let contents = try cssPath.loadContents()
    //            #expect(
    //                contents.contains(
    //                    """
    //                    body {
    //                      font: 100% Helvetica, sans-serif;
    //                      color: #333;
    //                    }
    //                    """
    //                )
    //            )
    //        }
    //    }
    //
    //    @Test
    //    func testSASSAssetModuleLoader() async throws {
    //        let logger = Logger(label: "ToucanTestSuite")
    //        try FileManagerPlayground {
    //            Directory(name: "src") {
    //                Directory(name: "contents") {
    //                    Directory(name: "page1") {
    //                        File(
    //                            name: "index.yaml",
    //                            string: """
    //                                title: title
    //                                type: page
    //                                description: Desc1
    //                                label: label1
    //                                """
    //                        )
    //                        Directory(name: "assets") {
    //                            File(
    //                                name: "_colors.scss",
    //                                string: """
    //                                    $primary: blue;
    //                                    """
    //                            )
    //                            File(
    //                                name: "style.scss",
    //                                string: """
    //                                    @use "colors";
    //
    //                                    body {
    //                                      color: colors.$primary;
    //                                    }
    //                                    """
    //                            )
    //                        }
    //                    }
    //                }
    //                Directory(name: "pipelines") {
    //                    File(
    //                        name: "html.yml",
    //                        string: """
    //                            id: html
    //                            assets:
    //                                behaviors:
    //                                    - id: compile-sass
    //                                      input:
    //                                        name: "style"
    //                                        ext: "scss"
    //                                      output:
    //                                        name: "style.min"
    //                                        ext: "css"
    //
    //                            contentTypes:
    //                                include:
    //                                    - page
    //                            engine:
    //                                id: mustache
    //                                options:
    //                                    contentTypes:
    //                                        page:
    //                                            template: "pages.default"
    //                            output:
    //                                path: "{{slug}}"
    //                                file: index
    //                                ext: html
    //                            """
    //                    )
    //                }
    //                Directory(name: "types") {
    //                    typePage()
    //                }
    //                Directory(name: "themes") {
    //                    Directory(name: "default") {
    //                        Directory(name: "templates") {
    //                            Directory(name: "pages") {
    //                                themeDefaultMustache(svg: "{{page.svg}}")
    //                            }
    //                            themeHtmlMustache()
    //                        }
    //                    }
    //                }
    //                configFile()
    //            }
    //        }
    //        .test {
    //            let input = $1.appending(path: "src/")
    //            let output = $1.appending(path: "docs/")
    //            try getToucan(input, output, logger).generate()
    //
    //            let assetsPath = output.appending(path: "assets/page1/")
    //
    //            #expect($0.listDirectory(at: assetsPath).count == 1)
    //
    //            let cssPath = assetsPath.appending(path: "style.min.css")
    //            #expect($0.fileExists(at: cssPath))
    //
    //            let contents = try cssPath.loadContents()
    //            #expect(
    //                contents.contains(
    //                    """
    //                    body {
    //                      color: blue;
    //                    }
    //                    """
    //                )
    //            )
    //        }
    //    }
    //

    //}
}
