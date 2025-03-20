//
//  File.swift
//  toucan
//
//  Created by Viasz-Kádi Ferenc on 2025. 03. 03..
//

import Foundation
import Testing
import ToucanTesting
import ToucanModels
import ToucanFileSystem
import FileManagerKitTesting
import ToucanSource
@testable import ToucanSDK

struct RawContentLoaderTestSuite {

    @Test
    func rawContentMarkdown() throws {
        try FileManagerPlayground {
            Directory("src") {
                Directory("contents") {
                    Directory("blog") {
                        Directory("articles") {
                            "noindex.yaml"
                            Directory("first-beta-release") {
                                File(
                                    "index.md",
                                    string: """
                                        ---
                                        type: post
                                        title: "First beta release"
                                        image: "./assets/cover.jpg"
                                        ---

                                        This is a dummy post!
                                        """
                                )
                                Directory("assets") {
                                    "image.png"
                                }
                            }
                        }
                    }
                }
            }
        }
        .test {
            let url = $1.appending(path: "src/contents/")
            let locator = RawContentLocator(
                fileManager: $0,
                fileType: .markdown
            )
            let locations = locator.locate(at: url)
            let decoder = ToucanYAMLDecoder()
            let sourceConfig = SourceConfig(
                sourceUrl: $1.appending(path: "src/"),
                config: .defaults
            )

            let loader = RawContentLoader(
                url: url,
                locations: locations,
                fileType: .markdown,
                sourceConfig: sourceConfig,
                frontMatterParser: FrontMatterParser(decoder: decoder),
                fileManager: $0,
                logger: .init(label: "RawContentLoaderTests"),
                baseUrl: "http://localhost:3000/"
            )
            let results = try loader.load()

            let result = try #require(results.first)

            #expect(
                result.origin
                    == .init(
                        path: "blog/articles/first-beta-release/index.md",
                        slug: "blog/first-beta-release"
                    )
            )
            #expect(
                result.frontMatter == [
                    "type": .init("post"),
                    "title": .init("First beta release"),
                    "image": .init(
                        "http://localhost:3000/assets/blog/first-beta-release/cover.jpg"
                    ),
                ]
            )
            #expect(result.markdown == "\n\nThis is a dummy post!")
            #expect(result.assets == ["image.png"])
        }
    }

    @Test
    func rawContentYaml() throws {
        try FileManagerPlayground {
            Directory("src") {
                Directory("contents") {
                    Directory("blog") {
                        Directory("articles") {
                            "noindex.yaml"
                            Directory("first-beta-release") {
                                File(
                                    "index.yml",
                                    string: """
                                        type: post
                                        title: "First beta release"
                                        image: "/images/cover.jpg"
                                        """
                                )
                                Directory("assets") {
                                    "image.png"
                                }
                            }
                        }
                    }
                }
            }
        }
        .test {
            let url = $1.appending(path: "src/contents/")
            let locator = RawContentLocator(fileManager: $0, fileType: .yaml)
            let locations = locator.locate(at: url)
            let decoder = ToucanYAMLDecoder()
            let sourceConfig = SourceConfig(
                sourceUrl: $1.appending(path: "src/"),
                config: .defaults
            )

            let loader = RawContentLoader(
                url: url,
                locations: locations,
                fileType: .yaml,
                sourceConfig: sourceConfig,
                frontMatterParser: FrontMatterParser(decoder: decoder),
                fileManager: $0,
                logger: .init(label: "RawContentLoaderTests"),
                baseUrl: "http://localhost:3000/"
            )
            let results = try loader.load()

            let result = try #require(results.first)

            #expect(
                result.origin
                    == .init(
                        path: "blog/articles/first-beta-release/index.yml",
                        slug: "blog/first-beta-release"
                    )
            )
            #expect(
                result.frontMatter == [
                    "type": .init("post"),
                    "title": .init("First beta release"),
                    "image": .init("http://localhost:3000/images/cover.jpg"),
                ]
            )
            #expect(result.assets == ["image.png"])
        }
    }

    @Test
    func invalidNoindexFileExtension() throws {
        try FileManagerPlayground {
            Directory("src") {
                Directory("contents") {
                    Directory("blog") {
                        Directory("articles") {
                            "noindex.md"
                            Directory("first-beta-release") {
                                File(
                                    "index.yml",
                                    string: """
                                        type: post
                                        title: "First beta release"
                                        image: "no-assets-prefix.jpg"
                                        """
                                )
                                Directory("assets") {
                                    "image.png"
                                }
                            }
                        }
                    }
                }
            }
        }
        .test {
            let url = $1.appending(path: "src/contents/")
            let locator = RawContentLocator(fileManager: $0, fileType: .yaml)
            let locations = locator.locate(at: url)
            let decoder = ToucanYAMLDecoder()
            let sourceConfig = SourceConfig(
                sourceUrl: $1.appending(path: "src/"),
                config: .defaults
            )

            let loader = RawContentLoader(
                url: url,
                locations: locations,
                fileType: .yaml,
                sourceConfig: sourceConfig,
                frontMatterParser: FrontMatterParser(decoder: decoder),
                fileManager: $0,
                logger: .init(label: "RawContentLoaderTests"),
                baseUrl: "http://localhost:3000/"
            )
            let results = try loader.load()

            let result = try #require(results.first)

            #expect(
                result.origin
                    == .init(
                        path: "blog/articles/first-beta-release/index.yml",
                        slug: "blog/articles/first-beta-release"
                    )
            )
            #expect(
                result.frontMatter == [
                    "type": .init("post"),
                    "title": .init("First beta release"),
                    "image": .init("no-assets-prefix.jpg"),
                ]
            )
            #expect(result.assets == ["image.png"])
        }
    }
}
