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

// TODO: fix this duplication
#warning("fix this")

extension String {
    func replacingOccurrences(
        _ dictionary: [String: String]
    ) -> String {
        var result = self
        for (key, value) in dictionary {
            result = result.replacingOccurrences(of: key, with: value)
        }
        return result
    }
}

@Suite
struct RawContentLocatorTestSuite {

    //    @Test()
    //    func rawContentLocatorEmpty() async throws {
    //        try FileManagerPlayground()
    //            .test {
    //                let locator = RawContentLocator(fileManager: $0)
    //                let locations = locator.locate(at: $1)
    //
    //                #expect(locations.isEmpty)
    //            }
    //    }
    //
    //    @Test()
    //    func rawContentLocatorTrimmingBrackets() async throws {
    //        try FileManagerPlayground {
    //            Directory("src") {
    //                Directory("contents") {
    //                    Directory("[01]blog") {
    //                        Directory("[01]articles") {
    //                            Directory("[01]first-beta-release") {
    //                                File("index.markdown")
    //                            }
    //                        }
    //                    }
    //                }
    //            }
    //        }
    //        .test {
    //            let url = $1.appending(path: "src/contents/")
    //            let locator = RawContentLocator(fileManager: $0)
    //            let results = locator.locate(at: url)
    //
    //            #expect(results.count == 1)
    //
    //            let result = try #require(results.first)
    //            let expected = RawContentLocation(
    //                slug: "blog/articles/first-beta-release",
    //                markdown:
    //                    "[01]blog/[01]articles/[01]first-beta-release/index.markdown"
    //                    .replacingOccurrences(["[": "%5B", "]": "%5D"])
    //            )
    //
    //            #expect(result == expected)
    //        }
    //    }
    //
    //    @Test()
    //    func rawContentLocatorNoindexBrackets() async throws {
    //        try FileManagerPlayground {
    //            Directory("src") {
    //                Directory("contents") {
    //                    Directory("[01]blog") {
    //                        Directory("[articles]") {
    //                            Directory("[01]first-beta-release") {
    //                                File("index.markdown")
    //                            }
    //                        }
    //                    }
    //                }
    //            }
    //        }
    //        .test {
    //            let url = $1.appending(path: "src/contents/")
    //            let locator = RawContentLocator(fileManager: $0)
    //            let results = locator.locate(at: url)
    //
    //            #expect(results.count == 1)
    //
    //            let result = try #require(results.first)
    //            let expected = RawContentLocation(
    //                slug: "blog/first-beta-release",
    //                markdown:
    //                    "[01]blog/[articles]/[01]first-beta-release/index.markdown"
    //                    .replacingOccurrences(["[": "%5B", "]": "%5D"])
    //            )
    //
    //            #expect(result == expected)
    //        }
    //    }
    //
    //    @Test()
    //    func rawContentLocatorMarkdownOnly() async throws {
    //        try FileManagerPlayground {
    //            Directory("src") {
    //                Directory("contents") {
    //                    Directory("blog") {
    //                        Directory("articles") {
    //                            "noindex.yaml"
    //                            Directory("first-beta-release") {
    //                                File("index.markdown")
    //                            }
    //                        }
    //                    }
    //                }
    //            }
    //        }
    //        .test {
    //            let url = $1.appending(path: "src/contents/")
    //            let locator = RawContentLocator(fileManager: $0)
    //            let results = locator.locate(at: url)
    //
    //            #expect(results.count == 1)
    //
    //            let result = try #require(results.first)
    //            let expected = RawContentLocation(
    //                slug: "blog/first-beta-release",
    //                markdown: "blog/articles/first-beta-release/index.markdown"
    //            )
    //
    //            #expect(result == expected)
    //        }
    //    }
    //
    //    @Test()
    //    func rawContentLocatorMdOnly() async throws {
    //        try FileManagerPlayground {
    //            Directory("src") {
    //                Directory("contents") {
    //                    Directory("blog") {
    //                        Directory("articles") {
    //                            "noindex.yaml"
    //                            Directory("first-beta-release") {
    //                                File("index.md")
    //                            }
    //                        }
    //                    }
    //                }
    //            }
    //        }
    //        .test {
    //            let url = $1.appending(path: "src/contents/")
    //            let locator = RawContentLocator(fileManager: $0)
    //            let results = locator.locate(at: url)
    //
    //            #expect(results.count == 1)
    //
    //            let result = try #require(results.first)
    //            let expected = RawContentLocation(
    //                slug: "blog/first-beta-release",
    //                md: "blog/articles/first-beta-release/index.md"
    //            )
    //
    //            #expect(result == expected)
    //        }
    //    }
    //
    //    @Test()
    //    func rawContentLocatorYamlOnly() async throws {
    //        try FileManagerPlayground {
    //            Directory("src") {
    //                Directory("contents") {
    //                    Directory("blog") {
    //                        Directory("articles") {
    //                            "noindex.yaml"
    //                            Directory("first-beta-release") {
    //                                File("index.yaml")
    //                            }
    //                        }
    //                    }
    //                }
    //            }
    //        }
    //        .test {
    //            let url = $1.appending(path: "src/contents/")
    //            let locator = RawContentLocator(fileManager: $0)
    //            let results = locator.locate(at: url)
    //
    //            #expect(results.count == 1)
    //
    //            let result = try #require(results.first)
    //            let expected = RawContentLocation(
    //                slug: "blog/first-beta-release",
    //                yaml: "blog/articles/first-beta-release/index.yaml"
    //            )
    //
    //            #expect(result == expected)
    //        }
    //    }
    //
    //    @Test()
    //    func rawContentLocatorYmlOnly() async throws {
    //        try FileManagerPlayground {
    //            Directory("src") {
    //                Directory("contents") {
    //                    Directory("blog") {
    //                        Directory("articles") {
    //                            "noindex.yaml"
    //                            Directory("first-beta-release") {
    //                                File("index.yml")
    //                            }
    //                        }
    //                    }
    //                }
    //            }
    //        }
    //        .test {
    //            let url = $1.appending(path: "src/contents/")
    //            let locator = RawContentLocator(fileManager: $0)
    //            let results = locator.locate(at: url)
    //
    //            #expect(results.count == 1)
    //
    //            let result = try #require(results.first)
    //            let expected = RawContentLocation(
    //                slug: "blog/first-beta-release",
    //                yml: "blog/articles/first-beta-release/index.yml"
    //            )
    //
    //            #expect(result == expected)
    //        }
    //    }
    //
    //    @Test()
    //    func rawContentLocatorMarkdowns() async throws {
    //        try FileManagerPlayground {
    //            Directory("src") {
    //                Directory("contents") {
    //                    Directory("blog") {
    //                        Directory("articles") {
    //                            "noindex.yaml"
    //                            Directory("first-beta-release") {
    //                                File("index.markdown")
    //                                File("index.md")
    //                            }
    //                        }
    //                    }
    //                }
    //            }
    //        }
    //        .test {
    //            let url = $1.appending(path: "src/contents/")
    //            let locator = RawContentLocator(fileManager: $0)
    //            let results = locator.locate(at: url)
    //
    //            #expect(results.count == 1)
    //
    //            let result = try #require(results.first)
    //            let expected = RawContentLocation(
    //                slug: "blog/first-beta-release",
    //                markdown: "blog/articles/first-beta-release/index.markdown",
    //                md: "blog/articles/first-beta-release/index.md"
    //            )
    //
    //            #expect(result == expected)
    //        }
    //    }
    //
    //    @Test()
    //    func rawContentLocatorYamls() async throws {
    //        try FileManagerPlayground {
    //            Directory("src") {
    //                Directory("contents") {
    //                    Directory("blog") {
    //                        Directory("articles") {
    //                            "noindex.yaml"
    //                            Directory("first-beta-release") {
    //                                File("index.yaml")
    //                                File("index.yml")
    //                            }
    //                        }
    //                    }
    //                }
    //            }
    //        }
    //        .test {
    //            let url = $1.appending(path: "src/contents/")
    //            let locator = RawContentLocator(fileManager: $0)
    //            let results = locator.locate(at: url)
    //
    //            #expect(results.count == 1)
    //
    //            let result = try #require(results.first)
    //            let expected = RawContentLocation(
    //                slug: "blog/first-beta-release",
    //                yaml: "blog/articles/first-beta-release/index.yaml",
    //                yml: "blog/articles/first-beta-release/index.yml"
    //            )
    //
    //            #expect(result == expected)
    //        }
    //    }
    //
    //    @Test()
    //    func rawContentLocatorAll() async throws {
    //        try FileManagerPlayground {
    //            Directory("src") {
    //                Directory("contents") {
    //                    Directory("blog") {
    //                        Directory("articles") {
    //                            "noindex.yaml"
    //                            Directory("first-beta-release") {
    //                                File("index.markdown")
    //                                File("index.md")
    //                                File("index.yaml")
    //                                File("index.yml")
    //                            }
    //                        }
    //                    }
    //                }
    //            }
    //        }
    //        .test {
    //            let url = $1.appending(path: "src/contents/")
    //            let locator = RawContentLocator(fileManager: $0)
    //            let results = locator.locate(at: url)
    //
    //            #expect(results.count == 1)
    //
    //            let result = try #require(results.first)
    //            let expected = RawContentLocation(
    //                slug: "blog/first-beta-release",
    //                markdown: "blog/articles/first-beta-release/index.markdown",
    //                md: "blog/articles/first-beta-release/index.md",
    //                yaml: "blog/articles/first-beta-release/index.yaml",
    //                yml: "blog/articles/first-beta-release/index.yml"
    //            )
    //
    //            #expect(result == expected)
    //        }
    //    }
}
