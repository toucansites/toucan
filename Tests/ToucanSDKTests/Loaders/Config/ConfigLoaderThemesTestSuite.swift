//
//  ConfigLoaderTestSuite.swift
//  Toucan
//
//  Created by Viasz-Kádi Ferenc on 2025. 02. 28..
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
                        pipelines:
                            testKey: testValue
                        contents:
                            path: contents
                            assets: 
                                path: assets
                        \(getThemes())
                        """
                )
            }
        }
        .test {
            let url = $1.appending(path: "src")
            let loader = getConfigLoader(url: url, logger: logger)
            let result = try loader.load()
            #expect(result == getResult())
        }
    }
    
    @Test("Test all theme paths", arguments: [
        [false, true, true, true, true, true, true],
        [true, false, true, true, true, true, true],
        [true, true, false, true, true, true, true],
        [true, true, true, false, true, true, true],
        [true, true, true, true, false, true, true],
        [true, true, true, true, true, false, true],
        [true, true, true, true, true, true, false]
    ])
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
            let loader = getConfigLoader(url: url, logger: logger)
            let result = try loader.load()
            #expect(result == getResult())
        }
    }
    
    private func getThemes(
        _ values: [Bool] = [true, true, true, true, true, true, true]
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
            types:
                    path: types
            """ : "")
            \(values[5] ? """
            overrides:
                    path: overrides 
            """ : "")
            \(values[6] ? """
            blocks:
                    path: blocks
            """ : "")
        """
    }
    
    private func getConfigLoader(url: URL, logger: Logger) -> ConfigLoader {
        return ConfigLoader(
            url: url,
            locations: [
                "config.yml"
            ],
            encoder: ToucanYAMLEncoder(),
            decoder: ToucanYAMLDecoder(),
            logger: logger
        )
    }
    
    private func getResult() -> Config {
        return Config(
            pipelines: .defaults,
            contents: .defaults,
            themes: .defaults,
            dateFormats: .defaults,
            contentConfigurations: .defaults
        )
    }
    
}
