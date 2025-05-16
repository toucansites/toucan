//
//  ConfigLoaderRendererConfigTestSuite.swift
//  Toucan
//
//  Created by gerp83 on 2025. 04. 15..
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
struct ConfigLoaderRendererConfigTestSuite {

    @Test
    func testParseDefaults() throws {
        let logger = Logger(label: "ConfigLoaderRendererConfigTestSuite")

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
            let result = try loader.load(Config.self)
            #expect(result == ConfigLoaderTestSuite.getDefaultResult())
        }
    }

    @Test(
        "Test all content configurations",
        arguments: [
            [false, true, true, false, false, false, false, false],
            [false, true, true, true, false, false, false, false],
            [false, true, true, false, true, false, false, false],
            [false, true, true, false, false, true, false, false],
            [false, true, true, false, false, false, true, false],
            [false, true, true, false, false, false, false, true],
            [true, false, true, false, false, false, false, false],
            [true, true, false, false, false, false, false, false],
        ]
    )
    func testParseOneMissing(_ values: [Bool]) throws {
        let logger = Logger(label: "ConfigLoaderRendererConfigTestSuite")

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
            let result = try loader.load(Config.self)
            #expect(result == ConfigLoaderTestSuite.getDefaultResult())
        }
    }

    private func getConfigarations(
        _ values: [Bool] = [true, true, true, true, true, true, true, true]
    ) -> String {
        return """
            renderer:
                \(values[0] ? """
            wordsPerMinute: 238
            """ : "")
                \(values[1] ? """
            outlineLevels:
                    - 2
                    - 3
            """ : "")
                \(values[2] ? getParagraphStyles([values[3], values[4], values[5], values[6], values[7]]) : "")
            """
    }

    private func getParagraphStyles(
        _ values: [Bool]
    ) -> String {
        return """
            paragraphStyles:
                    \(values[0] ? """
                    note:
                            - note
                    """ : "")
                    \(values[1] ? """
                    warn:
                            - warn
                            - warning
                    """ : "")
                    \(values[2] ? """
                    tip:
                            - tip
                    """ : "")
                    \(values[3] ? """
                    important:
                            - important
                    """ : "")
                    \(values[4] ? """
                    error:
                            - error
                            - caution
                    """ : "")
            """
    }

}
