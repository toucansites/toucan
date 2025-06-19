//
//  BuildTargetSourceLoaderTestSuite.swift
//  Toucan
//
//  Created by Binary Birds on 2025. 03. 04..

import FileManagerKit
import FileManagerKitBuilder
import Foundation
import Testing
import ToucanCore
import ToucanSerialization

@testable import ToucanSource

@Suite
struct BuildTargetSourceLoaderTestSuite {
    // MARK: - private helpers

    private func testSourceHierarchy(
        @FileManagerPlayground.DirectoryBuilder _ builder: () ->
            [FileManagerPlayground.Item]
    ) -> Directory {
        Directory(name: "src", builder)
    }

    private func testSourceTypesHierarchy(
        @FileManagerPlayground.DirectoryBuilder _ builder: () ->
            [FileManagerPlayground.Item]
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
            sourceURL: url,
            config: config
        )
        let loader = RawContentLoader(
            contentsURL: locations.contentsURL,
            assetsPath: config.contents.assets.path,
            decoder: .init(),
            markdownParser: .init(decoder: decoder),
            fileManager: fileManager
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
            sourceURL: url,
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
        let type1 = ContentType(
            id: "post"
        )
        let type2 = ContentType(
            id: "tag"
        )
        try FileManagerPlayground {
            testSourceTypesHierarchy {
                YAMLFile(name: "post", contents: type1)
                YAMLFile(name: "tag", contents: type2)
            }
        }
        .test {
            let sourceLoader = testSourceLoader(fileManager: $0, url: $1)
            let config = try sourceLoader.loadConfig()
            let locations = sourceLoader.getLocations(using: config)
            let results = try sourceLoader.loadTypes(using: locations)

            let exp: [ContentType] = [type1, type2]
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
                    string: ""
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
                    error.logMessage == "Could not load: `ContentType`."
                )
            }
            catch {
                Issue.record("Invalid error type: `\(type(of: error))`.")
            }
        }
    }

    // MARK: - blocks

    @Test
    func blocks() throws {
        try FileManagerPlayground {
            testSourceHierarchy {
                Directory(name: "blocks") {
                    YAMLFile(
                        name: "link",
                        contents: Block(
                            name: "link"
                        )
                    )
                    File(
                        name: "button.yml",
                        string: """
                            name: Button
                            tag: a
                            parameters:
                              - label: url
                                default: ""
                              - label: class
                                default: "button"
                              - label: target
                                default: "_blank"
                            removesChildParagraph: true
                            attributes:
                              - name: href
                                value: "{{url}}"
                              - name: target
                                value: "{{target}}"
                              - name: class
                                value: "{{class}}"
                            """
                    )
                }
            }
        }
        .test {
            let sourceLoader = testSourceLoader(fileManager: $0, url: $1)
            let config = try sourceLoader.loadConfig()
            let locations = sourceLoader.getLocations(using: config)
            let blocks = try sourceLoader.loadBlocks(using: locations)

            #expect(blocks.count == 2)
        }
    }

    // MARK: - valid source files

    @Test()
    func validSource() async throws {
        let type1 = ContentType(
            id: "post"
        )
        let type2 = ContentType(
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
                    YAMLFile(name: "post", contents: type1)
                    YAMLFile(name: "tag", contents: type2)
                }
                Directory(name: "blocks") {
                    YAMLFile(
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
            let buildTargetSource = try sourceLoader.load()
            #expect(buildTargetSource.blocks.count == 1)
            #expect(buildTargetSource.types.count == 2)
            #expect(buildTargetSource.rawContents.count == 4)
        }
    }

    // MARK: - config with target name

    @Test
    func configWithTargetName() async throws {
        var config = Config.defaults
        config.templates.current.path = "test"

        try FileManagerPlayground {
            testSourceHierarchy {
                YAMLFile(name: "config-dev", contents: config)
                YAMLFile(name: "config", contents: Config.defaults)
            }
        }
        .test {
            let sourceLoader = testSourceLoader(fileManager: $0, url: $1)
            let result = try sourceLoader.loadConfig()

            #expect(result.templates.current.path == "test")
        }
    }

    @Test
    func invalidConfigWithTargetName() async throws {
        try FileManagerPlayground {
            testSourceHierarchy {
                YAMLFile(name: "config-dev", contents: "invalid")
                YAMLFile(name: "config", contents: Config.defaults)
            }
        }
        .test {
            let sourceLoader = testSourceLoader(fileManager: $0, url: $1)

            do {
                _ = try sourceLoader.loadConfig()
                Issue.record("Invalid target config should throw an error.")
            }
            catch let error as SourceLoaderError {
                #expect(error.logMessage == "Could not load: `Config`.")
            }
        }
    }
}
