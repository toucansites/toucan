//
//  SourceLoaderTestSuite.swift
//  Toucan
//
//  Created by gerp83 on 2025. 04. 08..
//

import Foundation
import Testing
import ToucanModels
import ToucanTesting
import Logging
import FileManagerKitTesting
@testable import ToucanSource
@testable import ToucanSDK
@testable import ToucanFileSystem

@Suite
struct SourceLoaderTestSuite {

    @Test(arguments: [nil, "http://localhost:3000/"])
    func basicLoad(baseUrl: String?) throws {
        let logger = Logger(label: "SourceLoaderTestSuite")

        try FileManagerPlayground {
            Directory("src") {
                Directory("contents") {
                    Directory("home") {
                        File(
                            "index.md",
                            string: """
                                ---
                                slug: ""
                                title: "Home"
                                ---
                                """
                        )
                        Directory("assets") {
                            "image.png"
                            "cover.png"
                        }
                    }
                    File(
                        "site.yml",
                        string: """
                            baseUrl: http://localhost:3000/
                            name: Test
                            """
                    )
                }
                Directory("themes/default/types") {
                    File(
                        "page.yml",
                        string: """
                             id: page
                             default: true
                            """
                    )
                }
                Directory("pipelines") {
                    File(
                        "404.yml",
                        string: """
                            id: not-found
                            contentTypes: 
                                include:
                                    - "not-found"
                            engine: 
                                id: mustache
                                options:
                                    contentTypes: 
                                        not-found:
                                            template: "pages.404"
                            output:
                                path: ""
                                file: 404
                                ext: html
                            """
                    )
                }
                File(
                    "config.yml",
                    string: """
                        pipelines:
                            path: pipelines
                        """
                )
            }
        }
        .test {
            let sourceUrl = $1.appending(path: "src")
            let fs = ToucanFileSystem(fileManager: $0)
            let decoder = ToucanYAMLDecoder()
            let frontMatterParser = FrontMatterParser(
                decoder: decoder,
                logger: logger
            )

            let sourceLoader = SourceLoader(
                sourceUrl: sourceUrl,
                baseUrl: baseUrl,
                fileManager: $0,
                fs: fs,
                frontMatterParser: frontMatterParser,
                encoder: ToucanYAMLEncoder(),
                decoder: decoder,
                logger: logger
            )

            let sourceBundle = try sourceLoader.load()
            #expect(sourceBundle.contents.count == 1)
            #expect(sourceBundle.pipelines.count == 1)
        }

    }

}
