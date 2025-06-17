//
//  RawContentLoaderTestSuite.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 05. 19..
//

import FileManagerKit
import FileManagerKitBuilder
import Foundation
import Logging
import Testing
import ToucanSerialization

@testable import ToucanSource

@Suite
struct RawContentLoaderTestSuite {
    private func testSourceContentsHierarchy(
        @FileManagerPlayground.DirectoryBuilder _ builder: () ->
            [FileManagerPlayground.Item]
    ) -> Directory {
        Directory(name: "src") {
            Directory(name: "contents", builder)
        }
    }

    private func testRawContentLoader(
        fileManager: FileManagerKit,
        url: URL
    ) -> RawContentLoader {
        var logger = Logger(label: "test")
        logger.logLevel = .trace
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
            fileManager: fileManager,
            logger: logger
        )
        return loader
    }

    // MARK: - locate origin index file types

    private func testBlogArticleHierarchy(
        @FileManagerPlayground.DirectoryBuilder _ builder: () ->
            [FileManagerPlayground.Item]
    ) -> Directory {
        testSourceContentsHierarchy {
            Directory(name: "blog") {
                Directory(name: "articles") {
                    "noindex.yaml"
                    Directory(name: "first-beta-release", builder)
                }
            }
        }
    }

    private func testBlogArticleOrigin() -> Origin {
        .init(
            path: .init("blog/articles/first-beta-release"),
            slug: "blog/first-beta-release"
        )
    }

    private func testExpectationRequirements(
        fileManager: FileManagerKit,
        url: URL
    ) throws {
        let loader = testRawContentLoader(fileManager: fileManager, url: url)
        let results = loader.locateOrigins()
        #expect(results.count == 1)

        let result = try #require(results.first)
        let expected = testBlogArticleOrigin()

        #expect(result == expected)
    }

    // MARK: - origins

    @Test()
    func locateOriginsEmptyResults() async throws {
        try FileManagerPlayground()
            .test {
                let loader = testRawContentLoader(fileManager: $0, url: $1)
                let results = loader.locateOrigins()
                #expect(results.isEmpty)
            }
    }

    @Test()
    func locateOriginsWithNoIndexFile() async throws {
        try FileManagerPlayground {
            testSourceContentsHierarchy {
                Directory(name: "blog") {
                    Directory(name: "articles") {
                        "noindex.yaml"
                        Directory(name: "first-beta-release") {
                            "index.md"
                        }
                    }
                }
            }
        }
        .test {
            let loader = testRawContentLoader(fileManager: $0, url: $1)
            let results = loader.locateOrigins()
            #expect(results.count == 1)

            let result = try #require(results.first)
            let expected = Origin(
                path: .init("blog/articles/first-beta-release"),
                slug: "blog/first-beta-release"
            )
            #expect(result == expected)
        }
    }

    @Test()
    func locateOriginsIgnoreSlugBrackets() async throws {
        try FileManagerPlayground {
            testSourceContentsHierarchy {
                Directory(name: "[01]blog") {
                    Directory(name: "[01]articles") {
                        Directory(name: "[01]first-beta-release") {
                            "index.md"
                        }
                    }
                }
            }
        }
        .test {
            let loader = testRawContentLoader(fileManager: $0, url: $1)
            let results = loader.locateOrigins()
            #expect(results.count == 1)

            let result = try #require(results.first)
            let expected = Origin(
                path: .init(
                    "[01]blog/[01]articles/[01]first-beta-release"
                        .replacingOccurrences(of: "[", with: "%5B")
                        .replacingOccurrences(of: "]", with: "%5D")
                ),
                slug: "blog/articles/first-beta-release"
            )
            #expect(result == expected)
        }
    }

    @Test()
    func locateOriginsNoIndexBrackets() async throws {
        try FileManagerPlayground {
            testSourceContentsHierarchy {
                Directory(name: "[01]blog") {
                    Directory(name: "[articles]") {
                        Directory(name: "[02]first-beta-release") {
                            "index.md"
                        }
                    }
                }
            }
        }
        .test {
            let loader = testRawContentLoader(fileManager: $0, url: $1)
            let results = loader.locateOrigins()
            #expect(results.count == 1)

            let result = try #require(results.first)
            let expected = Origin(
                path: .init(
                    "[01]blog/[articles]/[02]first-beta-release"
                        .replacingOccurrences(of: "[", with: "%5B")
                        .replacingOccurrences(of: "]", with: "%5D")
                ),
                slug: "blog/first-beta-release"
            )
            #expect(result == expected)
        }
    }

    @Test(
        arguments: [
            ["index.md"],
            ["index.markdown"],
            ["index.yml"],
            ["index.yaml"],
            ["index.yml", "index.yaml"],
            ["index.md", "index.markdown"],
            ["index.md", "index.markdown", "index.yml", "index.yaml"],
        ]
    )
    func locateFiles(files: [String]) async throws {
        try FileManagerPlayground {
            testBlogArticleHierarchy { files.map { .file(.init(name: $0)) } }
        }
        .test {
            try testExpectationRequirements(fileManager: $0, url: $1)
        }
    }

    // MARK: - loading contents

    func testMarkdownFile(
        ext: String,
        modificationDate: Date
    ) -> File {
        File(
            name: "index.\(ext)",
            attributes: [
                .modificationDate: modificationDate
            ],
            string: """
                ---
                title: "Hello index.\(ext)"
                ---

                # Hello index.\(ext)

                Lorem ipsum dolor sit amet
                """
        )
    }

    func testYAMLFile(
        ext: String,
        modificationDate: Date
    ) -> File {
        File(
            name: "index.\(ext)",
            attributes: [
                .modificationDate: modificationDate
            ],
            string: """
                title: "Hello index.\(ext)"
                """
        )
    }

    func testAssetsDirectory() -> Directory {
        Directory(name: "assets") {
            "cover.png"
            "main.js"
            "style.css"
        }
    }

    func testExpectedRawContent(
        ext: String,
        emptyContents: Bool,
        modificationDate: Date
    ) -> RawContent {
        .init(
            origin: testBlogArticleOrigin(),
            markdown: .init(
                frontMatter: [
                    "title": "Hello index.\(ext)"
                ],
                contents: emptyContents
                    ? ""
                    : """
                    # Hello index.\(ext)

                    Lorem ipsum dolor sit amet
                    """
            ),
            lastModificationDate: modificationDate.timeIntervalSince1970,
            assetsPath: "assets",
            assets: [
                "cover.png",
                "main.js",
                "style.css",
            ]
            .sorted()
        )
    }

    @Test(
        arguments: [
            "md",
            "markdown",
        ]
    )
    func loadMarkdownContents(ext: String) async throws {
        let now = Date()

        try FileManagerPlayground {
            testBlogArticleHierarchy {
                testAssetsDirectory()
                testMarkdownFile(ext: ext, modificationDate: now)
            }
        }
        .test {
            let loader = testRawContentLoader(fileManager: $0, url: $1)
            let results = loader.locateOrigins()
            #expect(results.count == 1)

            let origin = try #require(results.first)
            let content = try loader.loadRawContent(at: origin)

            let expectation = testExpectedRawContent(
                ext: ext,
                emptyContents: false,
                modificationDate: now
            )

            #expect(content == expectation)
        }
    }

    @Test(
        arguments: [
            "yml",
            "yaml",
        ]
    )
    func loadYAMLContents(ext: String) async throws {
        let now = Date()

        try FileManagerPlayground {
            testBlogArticleHierarchy {
                testAssetsDirectory()
                testYAMLFile(ext: ext, modificationDate: now)
            }
        }
        .test {
            let loader = testRawContentLoader(fileManager: $0, url: $1)
            let results = loader.locateOrigins()
            #expect(results.count == 1)

            let origin = try #require(results.first)
            let content = try loader.loadRawContent(at: origin)

            let expectation = testExpectedRawContent(
                ext: ext,
                emptyContents: true,
                modificationDate: now
            )

            #expect(content == expectation)
        }
    }

    @Test()
    func loadMergedFileContents() async throws {
        let now = Date()

        try FileManagerPlayground {
            testBlogArticleHierarchy {
                Directory(name: "assets") {
                    "cover.png"
                    "style.css"
                    "main.js"
                }
                testMarkdownFile(ext: "md", modificationDate: now)
                testMarkdownFile(ext: "markdown", modificationDate: now)
                testYAMLFile(ext: "yml", modificationDate: now)
                testYAMLFile(ext: "yaml", modificationDate: now)
            }
        }
        .test {
            let loader = testRawContentLoader(fileManager: $0, url: $1)
            let results = loader.locateOrigins()
            #expect(results.count == 1)

            let origin = try #require(results.first)
            let content = try loader.loadRawContent(at: origin)

            let exp = RawContent(
                origin: testBlogArticleOrigin(),
                markdown: .init(
                    frontMatter: [
                        "title": "Hello index.yml"
                    ],
                    contents: """
                        # Hello index.md

                        Lorem ipsum dolor sit amet
                        """
                ),
                lastModificationDate: now.timeIntervalSince1970,
                assetsPath: "assets",
                assets: [
                    "cover.png",
                    "main.js",
                    "style.css",
                ]
                .sorted()
            )

            #expect(content.origin == exp.origin)
            #expect(content.markdown == exp.markdown)
            #expect(content.markdown.frontMatter == exp.markdown.frontMatter)
            #expect(content.markdown.contents == exp.markdown.contents)
            #expect(content.lastModificationDate == exp.lastModificationDate)
            #expect(content.assets == exp.assets)
            #expect(content == exp)
        }
    }

    @Test()
    func loadMultipleRawContents() async throws {
        let now = Date()

        try FileManagerPlayground {
            testSourceContentsHierarchy {
                Directory(name: "example-1") {
                    testMarkdownFile(ext: "md", modificationDate: now)
                }
                Directory(name: "example-2") {
                    testYAMLFile(ext: "yml", modificationDate: now)
                }
            }
        }
        .test {
            let loader = testRawContentLoader(fileManager: $0, url: $1)
            let results = try loader.load()
            #expect(results.count == 2)

            let expected: [RawContent] = [
                .init(
                    origin: .init(
                        path: .init("example-1"),
                        slug: "example-1"
                    ),
                    markdown: .init(
                        frontMatter: ["title": "Hello index.md"],
                        contents: """
                            # Hello index.md

                            Lorem ipsum dolor sit amet
                            """
                    ),
                    lastModificationDate: now.timeIntervalSince1970,
                    assetsPath: "assets",
                    assets: []
                ),
                .init(
                    origin: .init(
                        path: .init("example-2"),
                        slug: "example-2"
                    ),
                    markdown: .init(
                        frontMatter: ["title": "Hello index.yml"],
                        contents: ""
                    ),
                    lastModificationDate: now.timeIntervalSince1970,
                    assetsPath: "assets",
                    assets: []
                ),
            ]

            #expect(results == expected)
        }
    }
}
