//
//  File.swift
//  toucan
//
//  Created by Viasz-Kádi Ferenc on 2025. 03. 04..
//

import Logging
import Foundation
import Testing
import FileManagerKitTesting
@testable import ToucanFileSystem
import ToucanModels

@Suite
struct ContentAssetsWriterTestSuite {

    @Test()
    func testContentAssetsWriter() async throws {
        try FileManagerPlayground {
            Directory("src") {
                Directory("contents") {
                    Directory("assets") {
                        Directory("icons") {
                            "image.png"
                            "cover.png"
                        }
                        Directory("images") {
                            "image.png"
                            "cover.png"
                        }
                    }
                    Directory("home") {
                        File("index.md", string: "")
                        Directory("assets") {
                            "image.png"
                            "cover.png"
                        }
                    }
                    Directory("blog") {
                        Directory("authors") {
                            Directory("user1") {
                                File("index.md", string: "")
                                Directory("assets") {
                                    "image2.png"
                                    "cover2.png"
                                }
                            }
                            Directory("user2") {
                                File("index.md", string: "")
                                Directory("assets") {
                                    "image3.png"
                                    "cover3.png"
                                }
                            }
                        }
                    }
                }
            }
            Directory("workDir") {
                Directory("assets") {
                }
            }
        }

        .test {
            let contents = [
                Content(
                    id: "home",
                    slug: "",
                    rawValue: RawContent(
                        origin: .init(path: "home/index.md", slug: "home"),
                        frontMatter: [:],
                        markdown: "",
                        lastModificationDate: 1741879656.033987,
                        assets: ["image.png", "cover.png"]
                    ),
                    definition: ContentDefinition(
                        id: "page",
                        paths: [],
                        properties: [:],
                        relations: [:],
                        queries: [:]
                    ),
                    properties: [:],
                    relations: [:],
                    userDefined: [:],
                    iteratorInfo: nil
                ),
                Content(
                    id: "user1",
                    slug: "authors/user1",
                    rawValue: RawContent(
                        origin: .init(
                            path: "blog/authors/user1/index.md",
                            slug: "authors/user1"
                        ),
                        frontMatter: [:],
                        markdown: "",
                        lastModificationDate: 1741879656.033987,
                        assets: ["image2.png", "cover2.png"]
                    ),
                    definition: ContentDefinition(
                        id: "page",
                        paths: [],
                        properties: [:],
                        relations: [:],
                        queries: [:]
                    ),
                    properties: [:],
                    relations: [:],
                    userDefined: [:],
                    iteratorInfo: nil
                ),
                Content(
                    id: "user2",
                    slug: "authors/user2",
                    rawValue: RawContent(
                        origin: .init(
                            path: "blog/authors/user2/index.md",
                            slug: "authors/user2"
                        ),
                        frontMatter: [:],
                        markdown: "",
                        lastModificationDate: 1741879656.033987,
                        assets: ["image3.png", "cover3.png"]
                    ),
                    definition: ContentDefinition(
                        id: "page",
                        paths: [],
                        properties: [:],
                        relations: [:],
                        queries: [:]
                    ),
                    properties: [:],
                    relations: [:],
                    userDefined: [:],
                    iteratorInfo: nil
                ),
            ]

            let workDirUrl = $1.appending(path: "workDir/")
            let assetsFolder = workDirUrl.appending(path: "assets")
            let scrDirectory = $1.appending(path: "src/contents")

            let contentAssetsWriter = ContentAssetsWriter(
                fileManager: $0,
                assetsPath: "assets",
                assetsFolder: assetsFolder,
                scrDirectory: scrDirectory
            )
            for content in contents {
                try contentAssetsWriter.copyContentAssets(content: content)
            }

            let locator = FileLocator(fileManager: $0)

            var locations =
                locator.locate(at: workDirUrl.appending(path: "assets/home"))
                .sorted()
            #expect(locations == ["cover.png", "image.png"])

            locations =
                locator.locate(
                    at: workDirUrl.appending(path: "assets/authors/user1")
                )
                .sorted()
            #expect(locations == ["cover2.png", "image2.png"])

            locations =
                locator.locate(
                    at: workDirUrl.appending(path: "assets/authors/user2")
                )
                .sorted()
            #expect(locations == ["cover3.png", "image3.png"])
        }
    }

    @Test()
    func testContentAssetsWriterEmpty() async throws {
        try FileManagerPlayground {
            Directory("src") {
                Directory("contents") {
                    Directory("home") {
                        File("index.md", string: "")
                    }
                }
            }
            Directory("workDir") {
                Directory("assets") {
                }
            }
        }
        .test {

            let contents = [
                Content(
                    id: "home",
                    slug: "",
                    rawValue: RawContent(
                        origin: .init(path: "home/index.md", slug: "home"),
                        frontMatter: [:],
                        markdown: "",
                        lastModificationDate: 1741879656.033987,
                        assets: []
                    ),
                    definition: ContentDefinition(
                        id: "page",
                        paths: [],
                        properties: [:],
                        relations: [:],
                        queries: [:]
                    ),
                    properties: [:],
                    relations: [:],
                    userDefined: [:],
                    iteratorInfo: nil
                )
            ]

            let workDirUrl = $1.appending(path: "workDir/")
            let assetsFolder = workDirUrl.appending(path: "assets")
            let scrDirectory = $1.appending(path: "src/contents")

            let contentAssetsWriter = ContentAssetsWriter(
                fileManager: $0,
                assetsPath: "assets",
                assetsFolder: assetsFolder,
                scrDirectory: scrDirectory
            )
            for content in contents {
                try contentAssetsWriter.copyContentAssets(content: content)
            }

            let locator = FileLocator(fileManager: $0)
            let locations =
                locator.locate(at: workDirUrl.appending(path: "assets/home"))
                .sorted()
            #expect(locations.isEmpty)
        }
    }

}
