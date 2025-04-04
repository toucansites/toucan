//
//  RawContentLocatorTestSuite.swift
//  Toucan
//
//  Created by Viasz-Kádi Ferenc on 2025. 03. 04..
//

import Foundation
import Testing
import FileManagerKitTesting
@testable import ToucanFileSystem
import ToucanModels

@Suite
struct RawContentLocatorTestSuite {

    @Test()
    func rawContentLocatorEmpty() async throws {
        try FileManagerPlayground()
            .test {
                let locator = RawContentLocator(fileManager: $0)
                let locations = locator.locate(at: $1)

                #expect(locations.isEmpty)
            }
    }

    func rawContentLocatorMarkdownOnly() async throws {
        try FileManagerPlayground {
            Directory("src") {
                Directory("contents") {
                    Directory("blog") {
                        Directory("articles") {
                            "noindex.yaml"
                            Directory("first-beta-release") {
                                File("index.markdown")
                            }
                        }
                    }
                }
            }
        }
        .test {
            let url = $1.appending(path: "src/contents/")
            let locator = RawContentLocator(fileManager: $0)
            let results = locator.locate(at: url)

            #expect(results.count == 1)

            let result = try #require(results.first)
            let expected = RawContentLocation(
                slug: "blog/first-beta-release",
                markdown: "blog/articles/first-beta-release/index.markdown"
            )

            #expect(result == expected)
        }
    }

    @Test()
    func rawContentLocatorMdOnly() async throws {
        try FileManagerPlayground {
            Directory("src") {
                Directory("contents") {
                    Directory("blog") {
                        Directory("articles") {
                            "noindex.yaml"
                            Directory("first-beta-release") {
                                File("index.md")
                            }
                        }
                    }
                }
            }
        }
        .test {
            let url = $1.appending(path: "src/contents/")
            let locator = RawContentLocator(fileManager: $0)
            let results = locator.locate(at: url)

            #expect(results.count == 1)

            let result = try #require(results.first)
            let expected = RawContentLocation(
                slug: "blog/first-beta-release",
                md: "blog/articles/first-beta-release/index.md"
            )

            #expect(result == expected)
        }
    }

    func rawContentLocatorYamlOnly() async throws {
        try FileManagerPlayground {
            Directory("src") {
                Directory("contents") {
                    Directory("blog") {
                        Directory("articles") {
                            "noindex.yaml"
                            Directory("first-beta-release") {
                                File("index.yaml")
                            }
                        }
                    }
                }
            }
        }
        .test {
            let url = $1.appending(path: "src/contents/")
            let locator = RawContentLocator(fileManager: $0)
            let results = locator.locate(at: url)

            #expect(results.count == 1)

            let result = try #require(results.first)
            let expected = RawContentLocation(
                slug: "blog/first-beta-release",
                yaml: "blog/articles/first-beta-release/index.yaml"
            )

            #expect(result == expected)
        }
    }

    func rawContentLocatorYmlOnly() async throws {
        try FileManagerPlayground {
            Directory("src") {
                Directory("contents") {
                    Directory("blog") {
                        Directory("articles") {
                            "noindex.yaml"
                            Directory("first-beta-release") {
                                File("index.yml")
                            }
                        }
                    }
                }
            }
        }
        .test {
            let url = $1.appending(path: "src/contents/")
            let locator = RawContentLocator(fileManager: $0)
            let results = locator.locate(at: url)

            #expect(results.count == 1)

            let result = try #require(results.first)
            let expected = RawContentLocation(
                slug: "blog/first-beta-release",
                yml: "blog/articles/first-beta-release/index.yml"
            )

            #expect(result == expected)
        }
    }

    func rawContentLocatorMarkdowns() async throws {
        try FileManagerPlayground {
            Directory("src") {
                Directory("contents") {
                    Directory("blog") {
                        Directory("articles") {
                            "noindex.yaml"
                            Directory("first-beta-release") {
                                File("index.markdown")
                                File("index.md")
                            }
                        }
                    }
                }
            }
        }
        .test {
            let url = $1.appending(path: "src/contents/")
            let locator = RawContentLocator(fileManager: $0)
            let results = locator.locate(at: url)

            #expect(results.count == 1)

            let result = try #require(results.first)
            let expected = RawContentLocation(
                slug: "blog/first-beta-release",
                markdown: "blog/articles/first-beta-release/index.markdown",
                md: "blog/articles/first-beta-release/index.md"
            )

            #expect(result == expected)
        }
    }

    func rawContentLocatorYamls() async throws {
        try FileManagerPlayground {
            Directory("src") {
                Directory("contents") {
                    Directory("blog") {
                        Directory("articles") {
                            "noindex.yaml"
                            Directory("first-beta-release") {
                                File("index.yaml")
                                File("index.yml")
                            }
                        }
                    }
                }
            }
        }
        .test {
            let url = $1.appending(path: "src/contents/")
            let locator = RawContentLocator(fileManager: $0)
            let results = locator.locate(at: url)

            #expect(results.count == 1)

            let result = try #require(results.first)
            let expected = RawContentLocation(
                slug: "blog/first-beta-release",
                yaml: "blog/articles/first-beta-release/index.yaml",
                yml: "blog/articles/first-beta-release/index.yml"
            )

            #expect(result == expected)
        }
    }

    @Test()
    func rawContentLocatorAll() async throws {
        try FileManagerPlayground {
            Directory("src") {
                Directory("contents") {
                    Directory("blog") {
                        Directory("articles") {
                            "noindex.yaml"
                            Directory("first-beta-release") {
                                File("index.markdown")
                                File("index.md")
                                File("index.yaml")
                                File("index.yml")
                            }
                        }
                    }
                }
            }
        }
        .test {
            let url = $1.appending(path: "src/contents/")
            let locator = RawContentLocator(fileManager: $0)
            let results = locator.locate(at: url)

            #expect(results.count == 1)

            let result = try #require(results.first)
            let expected = RawContentLocation(
                slug: "blog/first-beta-release",
                markdown: "blog/articles/first-beta-release/index.markdown",
                md: "blog/articles/first-beta-release/index.md",
                yaml: "blog/articles/first-beta-release/index.yaml",
                yml: "blog/articles/first-beta-release/index.yml"
            )

            #expect(result == expected)
        }
    }
}
