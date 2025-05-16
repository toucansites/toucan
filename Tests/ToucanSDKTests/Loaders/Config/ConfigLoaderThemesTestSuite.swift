//
//  ConfigLoaderThemesTestSuite.swift
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
struct ConfigLoaderThemesTestSuite {

    @Test
    func testParseDefaults() throws {
        let logger = Logger(label: "ConfigLoaderThemesTestSuite")

        try FileManagerPlayground {
            Directory("src") {
                File(
                    "config.yml",
                    string: """
                        \(getThemes())
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
        "Test all theme paths",
        arguments: [
            [false, true, true, true, true],
            [true, false, true, true, true],
            [true, true, false, true, true],
            [true, true, true, false, true],
            [true, true, true, true, false],
        ]
    )
    func testParseOneMissing(_ values: [Bool]) throws {
        let logger = Logger(label: "ConfigLoaderThemesTestSuite")

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
                        \(getThemes(values))
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

    private func getThemes(
        _ values: [Bool] = [true, true, true, true, true]
    ) -> String {
        return """
            themes:
                \(values[0] ? """
            location:
                    path: themes
            """ : "")
                \(values[1] ? """
            current:
                    path: default
            """ : "")
                \(values[2] ? """
            assets:
                    path: assets
            """ : "")
                \(values[3] ? """
            templates:
                    path: templates
            """ : "")
                \(values[4] ? """
            overrides:
                    path: overrides 
            """ : "")
            """
    }

}
