////
////  SourceLoaderTestSuite.swift
////  Toucan
////
////  Created by gerp83 on 2025. 04. 08..
////
//
//import Foundation
//import Testing
//
//import Logging
//import FileManagerKitTesting
//import ToucanSerialization
//
//@testable import ToucanSDK
//
//@Suite
//struct SourceLoaderTestSuite: ToucanTestSuite {
//
//    @Test
//    func basicLoad() throws {
//        let logger = Logger(label: "SourceLoaderTestSuite")
//
//        try FileManagerPlayground {
//            Directory("src") {
//                File(
//                    "site.yml",
//                    string: """
//                        baseUrl: http://localhost:3000/
//                        name: Test
//                        """
//                )
//                Directory("contents") {
//                    File(
//                        "index.md",
//                        string: """
//                            ---
//                            slug: ""
//                            title: "Home"
//                            ---
//                            """
//                    )
//                    Directory("assets") {
//                        "image.png"
//                        "cover.png"
//                    }
//
//                }
//                Directory("types") {
//                    File(
//                        "page.yml",
//                        string: """
//                             id: page
//                             default: true
//                            """
//                    )
//                }
//                Directory("pipelines") {
//                    pipeline404()
//                }
//                File(
//                    "config.yml",
//                    string: """
//                        pipelines:
//                            path: pipelines
//                        """
//                )
//            }
//        }
//        .test {
//            let sourceUrl = $1.appending(path: "src")
//
//            let decoder = ToucanYAMLDecoder()
//            let markdownParser = MarkdownParser(
//                decoder: decoder,
//                logger: logger
//            )
//
//            let sourceLoader = SourceLoader(
//                sourceUrl: sourceUrl,
//                target: .standard,
//                fileManager: $0,
//                markdownParser: markdownParser,
//                encoder: ToucanYAMLEncoder(),
//                decoder: decoder,
//                logger: logger
//            )
//
//            let sourceBundle = try sourceLoader.load()
//            #expect(sourceBundle.contents.count == 1)
//            #expect(sourceBundle.pipelines.count == 1)
//        }
//    }
//}
