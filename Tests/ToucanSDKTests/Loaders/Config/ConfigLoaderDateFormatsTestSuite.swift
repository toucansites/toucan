//
//  ConfigLoaderDateFormatsTestSuite.swift
//  Toucan
//
//  Created by gerp83 on 2025. 04. 04.
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
struct ConfigLoaderDateFormatsTestSuite {
    
    @Test
    func testParseDefaults() throws {
        let logger = Logger(label: "ConfigLoaderDateFormatsTestSuite")
        
        try FileManagerPlayground {
            Directory("src") {
                File(
                    "config.yml",
                    string: """
                        \(getDateFormats())
                        """
                )
            }
        }
        .test {
            let url = $1.appending(path: "src")
            let loader = ConfigLoaderTestSuite.getConfigLoader(url: url, logger: logger)
            let result = try loader.load()
            #expect(result == ConfigLoaderTestSuite.getDefaultResult())
        }
    }
    
    @Test("Test all date formats", arguments: [
        [false, true],
        [true, false]
    ])
    func testParseOneMissing(_ values: [Bool]) throws {
        let logger = Logger(label: "ConfigLoaderDateFormatsTestSuite")
        
        try FileManagerPlayground {
            Directory("src") {
                File(
                    "config.yml",
                    string: """
                        \(getDateFormats(values))
                        """
                )
            }
        }
        .test {
            let url = $1.appending(path: "src")
            let loader = ConfigLoaderTestSuite.getConfigLoader(url: url, logger: logger)
            let result = try loader.load()
            #expect(result == ConfigLoaderTestSuite.getDefaultResult())
        }
    }
    
    private func getDateFormats(
        _ values: [Bool] = [true, true]
    ) -> String {
        return """
        dateFormats:
            \(values[0] ? """
            input:
                    format: yyyy-MM-dd'T'HH:mm:ss.SSS'Z'
            """ : "")
            \(values[1] ? """
            output:
            """ : "")
        """
    }
    
}
