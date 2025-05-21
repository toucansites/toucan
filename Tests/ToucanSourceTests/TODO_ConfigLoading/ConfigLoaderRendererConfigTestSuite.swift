//
//  ConfigLoaderRendererConfigTestSuite.swift
//  Toucan
//
//  Created by gerp83 on 2025. 04. 15..
//
//
//import Foundation
//import Testing
//
//
//import Logging
//import FileManagerKitTesting
//@testable import ToucanSDK
//
//@Suite
//struct ConfigLoaderRendererConfigTestSuite {
//
//    @Test()
//    func defaultValues() throws {
//        let logger = Logger(label: "ConfigLoaderRendererConfigTestSuite")
//
//        try FileManagerPlayground {
//            Directory("src") {
//                File(
//                    "config.yml",
//                    string: """
//                        pipelines:
//                            testKey: testValue
//                        contents:
//                            path: contents
//                            assets:
//                                path: assets
//                        renderer:
//                            wordsPerMinute: 238
//                            outlineLevels:
//                                - 2
//                                - 3
//                            paragraphStyles:
//                                note:
//                                    - note
//                                warning:
//                                    - warn
//                                    - warning
//                                tip:
//                                    - tip
//                                important:
//                                    - important
//                                error:
//                                    - error
//                                    - caution
//                        """
//                )
//            }
//        }
//        .test {
//            let url = $1.appending(path: "src")
//            let loader = ConfigLoaderTestSuite.getConfigLoader(
//                url: url,
//                logger: logger
//            )
//            let result = try loader.load(Config.self)
//            #expect(result == Config.defaults)
//        }
//    }
//
//}
