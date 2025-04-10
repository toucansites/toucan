//
//  ConfigLoaderContentConfigurationsTestSuite.swift
//  Toucan
//
//  Created by gerp83 on 2025. 04. 08.
//

import Foundation
import Testing
import ToucanModels
import ToucanTesting
import Logging
import FileManagerKitTesting
@testable import ToucanSource
@testable import ToucanSDK

@Suite
struct ConfigLoaderContentConfigurationsTestSuite {

    @Test
    func testParseDefaults() throws {
        let logger = Logger(label: "ConfigLoaderContentConfigurationsTestSuite")

        try FileManagerPlayground {
            Directory("src") {
                File(
                    "config.yml",
                    string: """
                        \(getConfigarations())
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
            let result = try loader.load()
            #expect(result == ConfigLoaderTestSuite.getDefaultResult())
        }
    }

    @Test(
        "Test all content configurations",
        arguments: [
            [false, true, true],
            [true, false, true],
            [true, true, false],
        ]
    )
    func testParseOneMissing(_ values: [Bool]) throws {
        let logger = Logger(label: "ConfigLoaderContentConfigurationsTestSuite")

        try FileManagerPlayground {
            Directory("src") {
                File(
                    "config.yml",
                    string: """
                        pipelines:
                            testKey: testValue
                        contents:
                            path: contents
                            assets: 
                                path: assets
                        \(getConfigarations(values))
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
            let result = try loader.load()
            #expect(result == ConfigLoaderTestSuite.getDefaultResult())
        }
    }

    private func getConfigarations(
        _ values: [Bool] = [true, true, true]
    ) -> String {
        return """
            contentConfigurations:
                \(values[0] ? """
            wordsPerMinute: 238
            """ : "")
                \(values[1] ? """
            outlineLevels:
                    - 2
                    - 3
            """ : "")
                \(values[2] ? """
            paragraphStyles:
                    note: 
                        - note
                    warn:
                        - warn
                        - warning
                    tip:
                        - tip
                    important:
                        - important
                    error:
                        - error
                        - caution
            """ : "")
            """
    }

}
