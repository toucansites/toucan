//
//  RawContentLoaderTestSuite.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 05. 19..
//

import Testing
import Foundation
import ToucanSerialization
import FileManagerKit
import FileManagerKitTesting

@testable import ToucanSource

@Suite
struct RawContentLoaderTestSuite {

    private func testSourceContentsHierarchy(
        @FileManagerPlayground.DirectoryBuilder
        _ builder: () -> [FileManagerPlayground.Item]
    ) -> Directory {
        Directory("src") {
            Directory("contents", builder)
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

    // MARK: - assets

    @Test()
    func locateAssetsStandardResult() async throws {
        try FileManagerPlayground {
            testSourceContentsHierarchy {
                Directory("example") {
                    Directory("assets") {
                        "image.png"
                        "cover.png"
                    }
                    "index.md"
                }
            }
        }
        .test {
            let url = $1.appending(path: "src/contents/example/assets")
            let loader = testRawContentLoader(fileManager: $0, url: $1)
            let results = loader.locateAssets(at: url)
            #expect(results.count == 2)
        }
    }

    @Test()
    func locateAssetsEmptyResult() async throws {
        try FileManagerPlayground()
            .test {
                let url = $1.appending(path: "src/contents/example/assets")
                let loader = testRawContentLoader(fileManager: $0, url: $1)
                let results = loader.locateAssets(at: url)
                #expect(results.isEmpty)
            }
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
    func locateOriginsNoIndexFile() async throws {
        try FileManagerPlayground {
            testSourceContentsHierarchy {
                Directory("blog") {
                    Directory("articles") {
                        "noindex.yaml"
                        Directory("first-beta-release") {
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
                path: "blog/articles/first-beta-release",
                slug: "blog/first-beta-release"
            )
            #expect(result == expected)
        }
    }

    @Test()
    func locateOriginsIgnoreSlugBrackets() async throws {
        try FileManagerPlayground {
            testSourceContentsHierarchy {
                Directory("[01]blog") {
                    Directory("[01]articles") {
                        Directory("[01]first-beta-release") {
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
                path: "[01]blog/[01]articles/[01]first-beta-release"
                    .replacingOccurrences(of: "[", with: "%5B")
                    .replacingOccurrences(of: "]", with: "%5D"),
                slug: "blog/articles/first-beta-release",
            )
            #expect(result == expected)
        }
    }

    @Test()
    func locateOriginsNoIndexBrackets() async throws {
        try FileManagerPlayground {
            testSourceContentsHierarchy {
                Directory("[01]blog") {
                    Directory("[articles]") {
                        Directory("[02]first-beta-release") {
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
                path: "[01]blog/[articles]/[02]first-beta-release"
                    .replacingOccurrences(of: "[", with: "%5B")
                    .replacingOccurrences(of: "]", with: "%5D"),
                slug: "blog/first-beta-release",
            )
            #expect(result == expected)
        }
    }

    // MARK: - locate origin index file types

    private func testBlogArticleHierarchy(
        @FileManagerPlayground.DirectoryBuilder
        _ builder: () -> [FileManagerPlayground.Item]
    ) -> Directory {
        testSourceContentsHierarchy {
            Directory("blog") {
                Directory("articles") {
                    "noindex.yaml"
                    Directory("first-beta-release", builder)
                }
            }
        }
    }

    private func testBlogArticleOrigin() -> Origin {
        .init(
            path: "blog/articles/first-beta-release",
            slug: "blog/first-beta-release",
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

    @Test()
    func locateMDFileOnly() async throws {
        try FileManagerPlayground {
            testBlogArticleHierarchy {
                "index.md"
            }
        }
        .test {
            try testExpectationRequirements(fileManager: $0, url: $1)
        }
    }

    @Test()
    func locateMarkdownFileOnly() async throws {
        try FileManagerPlayground {
            testBlogArticleHierarchy {
                "index.markdown"
            }
        }
        .test {
            try testExpectationRequirements(fileManager: $0, url: $1)
        }
    }

    @Test()
    func locateYMLFileOnly() async throws {
        try FileManagerPlayground {
            testBlogArticleHierarchy {
                "index.yml"
            }
        }
        .test {
            try testExpectationRequirements(fileManager: $0, url: $1)
        }
    }

    @Test()
    func locateYAMLFileOnly() async throws {
        try FileManagerPlayground {
            testBlogArticleHierarchy {
                "index.yaml"
            }
        }
        .test {
            try testExpectationRequirements(fileManager: $0, url: $1)
        }
    }

    @Test()
    func locateMutlipleYAMLFiles() async throws {
        try FileManagerPlayground {
            testBlogArticleHierarchy {
                "index.yaml"
                "index.yml"
            }
        }
        .test {
            try testExpectationRequirements(fileManager: $0, url: $1)
        }
    }

    @Test()
    func locateMutlipleMDFiles() async throws {
        try FileManagerPlayground {
            testBlogArticleHierarchy {
                "index.markdown"
                "index.md"
            }
        }
        .test {
            try testExpectationRequirements(fileManager: $0, url: $1)
        }
    }

    @Test()
    func locateAllIndexFiles() async throws {
        try FileManagerPlayground {
            testBlogArticleHierarchy {
                "index.markdown"
                "index.md"
                "index.yaml"
                "index.yml"
            }
        }
        .test {
            try testExpectationRequirements(fileManager: $0, url: $1)
        }
    }
}
