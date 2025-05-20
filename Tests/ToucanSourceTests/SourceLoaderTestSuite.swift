//
//  SourceLoaderTestSuite.swift
//  Toucan
//
//  Created by Binary Birds on 2025. 03. 04..

import Testing
import Foundation
import ToucanCore
import ToucanSerialization
import FileManagerKit
import FileManagerKitTesting

@testable import ToucanSource

@Suite
struct SourceLoaderTestSuite {

    // MARK: - private helpers

    private func testSourceHierarchy(
        @FileManagerPlayground.DirectoryBuilder
        _ builder: () -> [FileManagerPlayground.Item]
    ) -> Directory {
        Directory("src", builder)
    }

    private func testSourceTypesHierarchy(
        @FileManagerPlayground.DirectoryBuilder
        _ builder: () -> [FileManagerPlayground.Item]
    ) -> Directory {
        testSourceHierarchy {
            Directory("types", builder)
        }
    }

    private func testRawContentLoader(
        fileManager: FileManagerKit,
        url: URL
    ) -> RawContentLoader {
        let url = url.appending(path: "src/")
        let decoder = ToucanYAMLDecoder()
        let loader = RawContentLoader(
            locations: .init(sourceUrl: url, config: .defaults),
            decoder: .init(),
            markdownParser: .init(decoder: decoder),
            fileManager: fileManager,
        )
        return loader
    }

    private func testSourceLoader(
        fileManager: FileManagerKit,
        url: URL
    ) -> SourceLoader {
        let url = url.appending(path: "src/")
        let target = Target.standard
        let encoder = ToucanYAMLEncoder()
        let decoder = ToucanYAMLDecoder()
        let loader = SourceLoader(
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
                YAML(name: "post", contents: type1).file
                YAML(name: "tag", contents: type2).file
            }
        }
        .test {
            let sourceLoader = testSourceLoader(fileManager: $0, url: $1)
            let config = try sourceLoader.loadConfig()
            let locations = sourceLoader.getLocations(using: config)
            let results = try sourceLoader.loadTypes(
                using: locations,
                pipelines: []
            )

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
            let results = try sourceLoader.loadTypes(
                using: locations,
                pipelines: []
            )
            #expect(results.isEmpty)
        }
    }

    @Test()
    func invalidContentTypes() async throws {
        try FileManagerPlayground {
            testSourceTypesHierarchy {
                File(
                    "invalid.yaml",
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
                _ = try sourceLoader.loadTypes(
                    using: locations,
                    pipelines: []
                )
            }
            catch let error as SourceLoaderError {
                #expect(
                    error.logMessage == "Could not load: `ContentDefinition`."
                )
                // print(error.logMessageStack())
            }
            catch {
                Issue.record("Invalid error type: `\(type(of: error))`.")
            }
        }
    }

    // MARK: - source files

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
                Directory("contents") {
                    "index.md"
                    Directory("assets") {
                        "main.js"
                    }
                    Directory("404") {
                        "index.md"
                    }

                    Directory("blog") {
                        "noindex.yml"
                        Directory("authors") {
                            "index.md"
                        }
                    }
                    Directory("redirects") {
                        "noindex.yml"
                        Directory("home-old") {
                            "index.md"
                        }
                    }
                }
                Directory("types") {
                    YAML(name: "post", contents: type1).file
                    YAML(name: "tag", contents: type2).file
                }
                Directory("blocks") {
                    "link.yml"
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
        //            Directory("src") {
        //                Directory("contents") {
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
