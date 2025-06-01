//
//  BuildTargetSourceLoaderTestSuite.swift
//  Toucan
//
//  Created by Binary Birds on 2025. 03. 04..

import Testing
import Foundation
import ToucanCore
import ToucanSerialization
import FileManagerKit
import FileManagerKitBuilder

@testable import ToucanSource

@Suite
struct BuildTargetSourceLoaderTestSuite {

    // MARK: - private helpers

    private func testSourceHierarchy(
        @FileManagerPlayground.DirectoryBuilder
        _ builder: () -> [FileManagerPlayground.Item]
    ) -> Directory {
        Directory(name: "src", builder)
    }

    private func testSourceTypesHierarchy(
        @FileManagerPlayground.DirectoryBuilder
        _ builder: () -> [FileManagerPlayground.Item]
    ) -> Directory {
        testSourceHierarchy {
            Directory(name: "types", builder)
        }
    }

    private func testRawContentLoader(
        fileManager: FileManagerKit,
        url: URL
    ) -> RawContentLoader {
        let url = url.appending(path: "src/")
        let decoder = ToucanYAMLDecoder()
        let config = Config.defaults
        let locations = BuiltTargetSourceLocations(
            sourceUrl: url,
            config: config
        )
        let loader = RawContentLoader(
            contentsURL: locations.contentsUrl,
            assetsPath: config.contents.assets.path,
            decoder: .init(),
            markdownParser: .init(decoder: decoder),
            fileManager: fileManager,
        )
        return loader
    }

    private func testSourceLoader(
        fileManager: FileManagerKit,
        url: URL
    ) -> BuildTargetSourceLoader {
        let url = url.appending(path: "src/")
        let target = Target.standard
        let encoder = ToucanYAMLEncoder()
        let decoder = ToucanYAMLDecoder()
        let loader = BuildTargetSourceLoader(
            sourceUrl: url,
            target: target,
            fileManager: fileManager,
            encoder: encoder,
            decoder: decoder
        )
        return loader
    }

    // MARK: - content types

    @Test()
    func validContentTypes() async throws {
        let type1 = ContentDefinition(
            id: "post"
        )
        let type2 = ContentDefinition(
            id: "tag"
        )
        try FileManagerPlayground {
            testSourceTypesHierarchy {
                YAML(name: "post", contents: type1)
                YAML(name: "tag", contents: type2)
            }
        }
        .test {
            let sourceLoader = testSourceLoader(fileManager: $0, url: $1)
            let config = try sourceLoader.loadConfig()
            let locations = sourceLoader.getLocations(using: config)
            let results = try sourceLoader.loadTypes(using: locations)

            let exp: [ContentDefinition] = [type1, type2]
                .sorted(by: { $0.id < $1.id })

            #expect(results == exp)
        }
    }

    @Test()
    func emptyContentTypes() async throws {
        try FileManagerPlayground {
            testSourceTypesHierarchy {}
        }
        .test {
            let sourceLoader = testSourceLoader(fileManager: $0, url: $1)
            let config = try sourceLoader.loadConfig()
            let locations = sourceLoader.getLocations(using: config)
            let results = try sourceLoader.loadTypes(using: locations)
            #expect(results.isEmpty)
        }
    }

    @Test()
    func invalidContentTypes() async throws {
        try FileManagerPlayground {
            testSourceTypesHierarchy {
                File(
                    name: "invalid.yaml",
                    string: """
                        """
                )
            }
        }
        .test {
            do {
                let sourceLoader = testSourceLoader(fileManager: $0, url: $1)
                let config = try sourceLoader.loadConfig()
                let locations = sourceLoader.getLocations(using: config)
                _ = try sourceLoader.loadTypes(using: locations)
            }
            catch let error as SourceLoaderError {
                #expect(
                    error.logMessage == "Could not load: `ContentDefinition`."
                )
                //                print(error.logMessageStack())
            }
            catch {
                Issue.record("Invalid error type: `\(type(of: error))`.")
            }
        }
    }

    //    @Test
    //    func contentDefinitions() throws {
    //        try FileManagerPlayground {
    //            Directory(name: "src") {
    //                Directory(name: "types") {
    //                    File(
    //                        "foo.yml",
    //                        string: """
    //                            id: foo
    //                            paths:
    //                            properties:
    //                            relations:
    //                            queries:
    //                            """
    //                    )
    //                    File(
    //                        "bar.yml",
    //                        string: """
    //                            id: bar
    //                            paths:
    //                            properties:
    //                            relations:
    //                            queries:
    //                            """
    //                    )
    //                }
    //            }
    //        }
    //        .test {
    //            let url = $1.appending(path: "src/types/")
    //            let loader = ContentDefinitionLoader(
    //                url: url,
    //                locations: [
    //                    "foo.yml",
    //                    "bar.yml",
    //                ],
    //                decoder: ToucanYAMLDecoder()
    //            )
    //            let result = try loader.load()
    //
    //            #expect(
    //                result == [
    //                    .init(
    //                        id: "foo",
    //                        paths: [],
    //                        properties: [:],
    //                        relations: [:],
    //                        queries: [:]
    //                    ),
    //                    .init(
    //                        id: "bar",
    //                        paths: [],
    //                        properties: [:],
    //                        relations: [:],
    //                        queries: [:]
    //                    ),
    //                ]
    //            )
    //        }
    //    }

    // MARK: - blocks

    //    @Test
    //    func loadMarkdownBlockDirectives() throws {
    //        let logger = Logger(label: "BlockDirectiveLoaderTests")
    //        try FileManagerPlayground {
    //            Directory(name: "src") {
    //                Directory(name: "blocks") {
    //                    File(
    //                        "highlighted-text.yml",
    //                        string: """
    //                            name: HighlightedText
    //                            tag: div
    //                            attributes:
    //                              - name: class
    //                                value: highlighted-text
    //                            """
    //                    )
    //                    File(
    //                        "button.yml",
    //                        string: """
    //                            name: Button
    //                            tag: a
    //                            parameters:
    //                              - label: url
    //                                default: ""
    //                              - label: class
    //                                default: "button"
    //                              - label: target
    //                                default: "_blank"
    //                            removesChildParagraph: true
    //                            attributes:
    //                              - name: href
    //                                value: "{{url}}"
    //                              - name: target
    //                                value: "{{target}}"
    //                              - name: class
    //                                value: "{{class}}"
    //                            """
    //                    )
    //                }
    //            }
    //        }
    //        .test {
    //            let url = $1.appending(path: "src/blocks/")
    //
    //            let loader = BlockDirectiveLoader(
    //                url: url,
    //                locations: [
    //                    "highlighted-text.yml",
    //                    "button.yml",
    //                ],
    //                decoder: ToucanYAMLDecoder(),
    //                logger: logger
    //            )
    //            let result = try loader.load()
    //
    //            #expect(
    //                result == [
    //                    .init(
    //                        name: "HighlightedText",
    //                        parameters: nil,
    //                        requiresParentDirective: nil,
    //                        removesChildParagraph: nil,
    //                        tag: "div",
    //                        attributes: [
    //                            MarkdownBlockDirective.Attribute(
    //                                name: "class",
    //                                value: "highlighted-text"
    //                            )
    //                        ],
    //                        output: nil
    //                    ),
    //                    .init(
    //                        name: "Button",
    //                        parameters: [
    //                            MarkdownBlockDirective.Parameter(
    //                                label: "url",
    //                                isRequired: nil,
    //                                defaultValue: ""
    //                            ),
    //                            MarkdownBlockDirective.Parameter(
    //                                label: "class",
    //                                isRequired: nil,
    //                                defaultValue: "button"
    //                            ),
    //                            MarkdownBlockDirective.Parameter(
    //                                label: "target",
    //                                isRequired: nil,
    //                                defaultValue: "_blank"
    //                            ),
    //                        ],
    //                        requiresParentDirective: nil,
    //                        removesChildParagraph: true,
    //                        tag: "a",
    //                        attributes: [
    //                            MarkdownBlockDirective.Attribute(
    //                                name: "href",
    //                                value: "{{url}}"
    //                            ),
    //                            MarkdownBlockDirective.Attribute(
    //                                name: "target",
    //                                value: "{{target}}"
    //                            ),
    //                            MarkdownBlockDirective.Attribute(
    //                                name: "class",
    //                                value: "{{class}}"
    //                            ),
    //                        ],
    //                        output: nil
    //                    ),
    //                ]
    //            )
    //        }
    //    }

    // MARK: - pipelines

    //    @Test
    //    func basicLoad() throws {
    //        let logger = Logger(label: "PipelineLoaderTestSuite")
    //        try FileManagerPlayground {
    //            Directory(name: "src") {
    //                Directory(name: "pipelines") {
    //                    pipeline404(addTransformers: true)
    //                    pipelineRedirect()
    //                }
    //                File(
    //                    "config.yml",
    //                    string: """
    //                        pipelines:
    //                            path: pipelines
    //                        """
    //                )
    //            }
    //        }
    //        .test {
    //            let sourceUrl = $1.appending(path: "src")
    //            let loader = ConfigLoaderTestSuite.getConfigLoader(
    //                url: sourceUrl,
    //                logger: logger
    //            )
    //            let config = try loader.load(Config.self)
    //
    //            let sourceConfig = SourceConfig(
    //                sourceUrl: sourceUrl,
    //                config: config
    //            )
    //
    //            let fs = ToucanFileSystem(fileManager: $0)
    //            let pipelineLocations = fs.pipelineLocator.locate(
    //                at: sourceConfig.pipelinesUrl
    //            )
    //            let pipelineLoader = PipelineLoader(
    //                url: sourceConfig.pipelinesUrl,
    //                locations: pipelineLocations,
    //                decoder: ToucanYAMLDecoder(),
    //                logger: logger
    //            )
    //            let pipelines = try pipelineLoader.load()
    //            #expect(pipelines.count == 2)
    //            #expect(pipelines[1].transformers.count == 2)
    //        }
    //
    //    }
    //
    //    @Test
    //    func loadAssets() throws {
    //        let logger = Logger(label: "PipelineLoaderTestSuite")
    //        try FileManagerPlayground {
    //            Directory(name: "src") {
    //                Directory(name: "pipelines") {
    //                    pipelineSitemap(
    //                        """
    //                        assets:
    //                          properties:
    //                            - action: add
    //                              property: js
    //                              resolvePath: false
    //                              input:
    //                                name: main
    //                                ext: js
    //                            - action: set
    //                              property: image
    //                              resolvePath: true
    //                              input:
    //                                name: cover
    //                                ext: jpg
    //                            - action: load
    //                              property: svgs
    //                              resolvePath: false
    //                              input:
    //                                name: "*"
    //                                ext: svg
    //                            - action: parse
    //                              property: data
    //                              resolvePath: false
    //                              input:
    //                                name: "*"
    //                                ext: json
    //                        """
    //                    )
    //                }
    //                File(
    //                    "config.yml",
    //                    string: """
    //                        pipelines:
    //                            path: pipelines
    //                        """
    //                )
    //            }
    //        }
    //        .test {
    //            let sourceUrl = $1.appending(path: "src")
    //            let loader = ConfigLoaderTestSuite.getConfigLoader(
    //                url: sourceUrl,
    //                logger: logger
    //            )
    //            let config = try loader.load(Config.self)
    //
    //            let sourceConfig = SourceConfig(
    //                sourceUrl: sourceUrl,
    //                config: config
    //            )
    //
    //            let fs = ToucanFileSystem(fileManager: $0)
    //            let pipelineLocations = fs.pipelineLocator.locate(
    //                at: sourceConfig.pipelinesUrl
    //            )
    //            let pipelineLoader = PipelineLoader(
    //                url: sourceConfig.pipelinesUrl,
    //                locations: pipelineLocations,
    //                decoder: ToucanYAMLDecoder(),
    //                logger: logger
    //            )
    //            let pipelines = try pipelineLoader.load()
    //            #expect(pipelines.count == 1)
    //            #expect(pipelines[0].assets.properties.count == 4)
    //            #expect(pipelines[0].assets.properties[0].action == .add)
    //            #expect(pipelines[0].assets.properties[1].action == .set)
    //            #expect(pipelines[0].assets.properties[2].action == .load)
    //            #expect(pipelines[0].assets.properties[3].action == .parse)
    //        }
    //    }

    // MARK: - settings

    //    @Test
    //    func basicSettings() throws {
    //        let logger = Logger(label: "SettingsLoaderTestSuite")
    //        try FileManagerPlayground {
    //            Directory(name: "src") {
    //                File(
    //                    "site.yml",
    //                    string: """
    //                        baseUrl: http://localhost:8080/
    //                        name: Test
    //                        """
    //                )
    //            }
    //        }
    //        .test {
    //            let url = $1.appending(path: "src/")
    //
    //            let settings = try ObjectLoader(
    //                url: url,
    //                locations: $0.find(
    //                    name: "site",
    //                    extensions: ["yaml", "yml"],
    //                    at: url
    //                ),
    //                encoder: ToucanYAMLEncoder(),
    //                decoder: ToucanYAMLDecoder(),
    //                logger: logger
    //            )
    //            .load(Settings.self)
    //
    //            let expectation = Settings(
    //                [
    //                    "baseUrl": "http://localhost:8080/",
    //                    "name": "Test",
    //                ]
    //            )
    //            #expect(settings == expectation)
    //        }
    //    }

    // MARK: - valid source files

    @Test()
    func validSource() async throws {
        let type1 = ContentDefinition(
            id: "post"
        )
        let type2 = ContentDefinition(
            id: "tag"
        )

        try FileManagerPlayground {
            testSourceHierarchy {
                Directory(name: "contents") {
                    "index.md"
                    Directory(name: "assets") {
                        "main.js"
                    }
                    Directory(name: "404") {
                        "index.md"
                    }

                    Directory(name: "blog") {
                        "noindex.yml"
                        Directory(name: "authors") {
                            "index.md"
                        }
                    }
                    Directory(name: "redirects") {
                        "noindex.yml"
                        Directory(name: "home-old") {
                            "index.md"
                        }
                    }
                }
                Directory(name: "types") {
                    YAML(name: "post", contents: type1)
                    YAML(name: "tag", contents: type2)
                }
                Directory(name: "blocks") {
                    YAML(
                        name: "link",
                        contents: Block(
                            name: "link"
                        )
                    )
                }
            }
        }
        .test {
            let sourceLoader = testSourceLoader(fileManager: $0, url: $1)
            do {
                let source = try sourceLoader.load()
                print(source)
            }
            catch let error as SourceLoaderError {
                print(error.logMessageStack())
                Issue.record(error)
            }

        }

        //    @Test()
        //    func fileSystem_SettingsLocator() async throws {
        //        try FileManagerPlayground {
        //            Directory(name: "src") {
        //                Directory(name: "contents") {
        //                    "site.yml"
        //                    "site.yaml"
        //                    "index.yml"
        //                    "index.md"
        //                }
        //            }
        //        }
        //        .test {
        //            let fs = ToucanFileSystem(fileManager: $0)
        //            let url = $1.appending(path: "src/contents/")
        //            let locations = fs.settingsLocator.locate(at: url)
        //
        //            #expect(locations.sorted() == ["site.yaml", "site.yml"])
        //        }
        //    }
    }
}
