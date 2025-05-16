//
//  SettingsLoaderTestSuite.swift
//  Toucan
//
//  Created by Viasz-Kádi Ferenc on 2025. 02. 28..
//

import Foundation
import Testing
import ToucanModels

import Logging
import FileManagerKitTesting
import ToucanSerialization
@testable import ToucanSDK
@testable import ToucanFileSystem

@Suite
struct SettingsLoaderTestSuite {

    @Test
    func basicSettings() throws {
        let logger = Logger(label: "SettingsLoaderTestSuite")
        try FileManagerPlayground {
            Directory("src") {
                File(
                    "site.yml",
                    string: """
                        baseUrl: http://localhost:8080/
                        name: Test
                        """
                )
            }
        }
        .test {
            let url = $1.appending(path: "src/")

            let settings = try ObjectLoader(
                url: url,
                locations: $0.find(
                    name: "site",
                    extensions: ["yaml", "yml"],
                    at: url
                ),
                encoder: ToucanYAMLEncoder(),
                decoder: ToucanYAMLDecoder(),
                logger: logger
            )
            .load(Settings.self)

            let expectation = Settings(
                [
                    "baseUrl": "http://localhost:8080/",
                    "name": "Test",
                ]
            )
            #expect(settings == expectation)
        }
    }
}
