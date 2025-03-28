//
//  File.swift
//  toucan
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
struct ConfigLoaderTestSuite {

    @Test
    func config() throws {
        let logger = Logger(label: "ConfigLoaderTestSuite")
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
                        dateFormats:
                            input: y
                        contentConfigurations:
                            wordsPerMinute: 240
                            outlineLevels:
                                - 3
                                - 4
                            paragraphStyles:
                                note: 
                                    - note
                                warn:
                                    - warn
                                    - warning
                        """
                )
            }
        }
        .test {
            let url = $1.appending(path: "src")
            let loader = ConfigLoader(
                url: url,
                locations: [
                    "config.yml"
                ],
                encoder: ToucanYAMLEncoder(),
                decoder: ToucanYAMLDecoder(),
                logger: logger
            )
            let result = try loader.load()

            #expect(
                result
                    == Config(
                        pipelines: .defaults,
                        contents: .defaults,
                        themes: .defaults,
                        dateFormats: .init(input: "y", output: [:]),
                        contentConfigurations: .init(
                            wordsPerMinute: 240,
                            outlineLevels: [3, 4],
                            paragraphStyles: .init(note: ["note"], warn: ["warn", "warning"])
                        )
                    )
            )
        }
    }
}
