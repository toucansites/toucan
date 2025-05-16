//
//  ConfigLoaderPipelinesTestSuite.swift
//  Toucan
//
//  Created by gerp83 on 2025. 04. 15..
//

import Foundation
import Testing
import ToucanModels

import Logging
import FileManagerKitTesting
@testable import ToucanSDK

@Suite
struct ConfigLoaderPipelinesTestSuite {

    @Test
    func testParseDefaults() throws {
        let logger = Logger(label: "ConfigLoaderPipelinesTestSuite")

        try FileManagerPlayground {
            Directory("src") {
                File(
                    "config.yml",
                    string: """
                        \(getPipelines())
                        """
                )
            }
        }
        .test {
            let url = $1.appending(path: "src")
            let loader = ConfigLoaderTestSuite.getConfigLoader(
                url: url,
                logger: logger
            )
            let result = try loader.load(Config.self)
            #expect(result == ConfigLoaderTestSuite.getDefaultResult())
        }
    }

    @Test("Test all pipelines", arguments: [[false]])
    func testParseOneMissing(_ values: [Bool]) throws {
        let logger = Logger(label: "ConfigLoaderPipelinesTestSuite")

        try FileManagerPlayground {
            Directory("src") {
                File(
                    "config.yml",
                    string: """
                        \(getPipelines(values))
                        """
                )
            }
        }
        .test {
            let url = $1.appending(path: "src")
            let loader = ConfigLoaderTestSuite.getConfigLoader(
                url: url,
                logger: logger
            )
            let result = try loader.load(Config.self)
            #expect(result == ConfigLoaderTestSuite.getDefaultResult())
        }
    }

    private func getPipelines(
        _ values: [Bool] = [true]
    ) -> String {
        return """
            pipelines:
                \(values[0] ? """
            path: pipelines
            """ : "")
            """
    }

}
