//
//  ConfigLoaderContentsTestSuite.swift
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
//struct ConfigLoaderContentsTestSuite {
//
//    @Test
//    func testParseDefaults() throws {
//        let logger = Logger(label: "ConfigLoaderContentsTestSuite")
//
//        try FileManagerPlayground {
//            Directory("src") {
//                File(
//                    "config.yml",
//                    string: """
//                        \(getContents())
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
//            #expect(result == ConfigLoaderTestSuite.getDefaultResult())
//        }
//    }
//
//    @Test(
//        "Test all date formats",
//        arguments: [
//            [false, true],
//            [true, false],
//        ]
//    )
//    func testParseOneMissing(_ values: [Bool]) throws {
//        let logger = Logger(label: "ConfigLoaderContentsTestSuite")
//
//        try FileManagerPlayground {
//            Directory("src") {
//                File(
//                    "config.yml",
//                    string: """
//                        \(getContents(values))
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
//            #expect(result == ConfigLoaderTestSuite.getDefaultResult())
//        }
//    }
//
//    private func getContents(
//        _ values: [Bool] = [true, true]
//    ) -> String {
//        return """
//            contents:
//                \(values[0] ? """
//            path: contents
//            """ : "")
//                \(values[1] ? """
//            assets:
//                    path: assets
//            """ : "")
//            """
//    }
//
//}
