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
                            input: 
                                format: y
                            output:
                                hu:
                                    locale: hu-HU
                                    timeZone: CET
                                    format: "y.MM.dd"
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
                        dateFormats: .init(
                            input: .init(format: "y"),
                            output: [
                                "hu": .init(
                                    locale: "hu-HU",
                                    timeZone: "CET",
                                    format: "y.MM.dd"
                                )
                            ]
                        )
                    )
            )
        }
    }
}
