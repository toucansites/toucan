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
import Logging
@testable import ToucanSDK

struct RawContentLoaderTestSuite {

    @Test
    func rawContentMarkdown() throws {
        let logger = Logger(label: "RawContentLoaderTestSuite")
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
                logger: logger,
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
            #expect(result.frontMatter["type"] == .init("post"))
            #expect(result.frontMatter["title"] == .init("First beta release"))
            #expect(
                result.frontMatter["image"]
                    == .init(
                        "http://localhost:3000/assets/blog/first-beta-release/cover.jpg"
                    )
            )
            #expect(result.markdown == "\n\nThis is a dummy post!")
            #expect(result.assets == ["image.png"])
        }
    }

    @Test
    func rawContentYaml() throws {
        let logger = Logger(label: "RawContentLoaderTestSuite")
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
                logger: logger,
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
            #expect(result.frontMatter["type"] == .init("post"))
            #expect(result.frontMatter["title"] == .init("First beta release"))
            #expect(
                result.frontMatter["image"]
                    == .init("http://localhost:3000/images/cover.jpg")
            )
            #expect(result.assets == ["image.png"])
        }
    }

    @Test
    func invalidNoindexFileExtension() throws {
        let logger = Logger(label: "RawContentLoaderTestSuite")
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
                logger: logger,
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
            #expect(result.frontMatter["type"] == .init("post"))
            #expect(result.frontMatter["title"] == .init("First beta release"))
            #expect(
                result.frontMatter["image"] == .init("no-assets-prefix.jpg")
            )
            #expect(result.assets == ["image.png"])
        }
    }

    @Test
    func rawContentCoverImage() throws {
        let logger = Logger(label: "RawContentLoaderTestSuite")
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
                                        ---

                                        This is a dummy post!
                                        """
                                )
                                Directory("assets") {
                                    "cover.jpg"
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
                logger: logger,
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
            #expect(result.frontMatter["type"] == .init("post"))
            #expect(result.frontMatter["title"] == .init("First beta release"))
            #expect(
                result.frontMatter["image"]
                    == .init(
                        "http://localhost:3000/assets/blog/first-beta-release/cover.jpg"
                    )
            )
            #expect(result.markdown == "\n\nThis is a dummy post!")
            #expect(result.assets == ["cover.jpg"])
        }
    }

    @Test
    func rawContentJsCss() throws {
        let logger = Logger(label: "RawContentLoaderTestSuite")
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
                                        ---

                                        This is a dummy post!
                                        """
                                )
                                Directory("assets") {
                                    "main.js"
                                    "style.css"
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
                logger: logger,
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
            #expect(result.frontMatter["type"] == .init("post"))
            #expect(result.frontMatter["title"] == .init("First beta release"))
            #expect(result.frontMatter["image"] == .init(nil))
            #expect(result.markdown == "\n\nThis is a dummy post!")
            #expect(
                result.assets.sorted() == ["main.js", "style.css"].sorted()
            )
        }
    }
}
