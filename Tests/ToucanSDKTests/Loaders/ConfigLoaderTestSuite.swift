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
import FileManagerKitTesting
@testable import ToucanSource
@testable import ToucanSDK

@Suite
struct ConfigLoaderTestSuite {

    @Test
    func config() throws {
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
                logger: .init(label: "ConfigLoaderTests")
            )
            let result = try loader.load()

            #expect(
                result
                    == Config(
                        pipelines: .defaults,
                        contents: .defaults,
                        themes: .defaults,
                        dateFormats: .init(input: "y", output: [:])
                    )
            )
        }
    }
}
