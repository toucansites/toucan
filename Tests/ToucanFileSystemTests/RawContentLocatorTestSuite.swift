//
//  File.swift
//  toucan
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
    func rawContentLocator() async throws {
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
            let results = locator.locate(at: url)

            #expect(results.count == 1)

            let result = try #require(results.first)
            let expected = Origin(
                path: "blog/articles/first-beta-release/index.md",
                slug: "blog/first-beta-release"
            )

            #expect(result == expected)
        }
    }

    @Test()
    func rawContentLocatorEmpty() async throws {
        try FileManagerPlayground()
            .test {
                let locator = RawContentLocator(
                    fileManager: $0,
                    fileType: .yaml
                )
                let locations = locator.locate(at: $1)

                #expect(locations.isEmpty)
            }
    }
}
