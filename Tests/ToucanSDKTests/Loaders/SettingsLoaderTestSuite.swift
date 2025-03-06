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
@testable import ToucanFileSystem

@Suite
struct SettingsLoaderTestSuite {

    @Test
    func settings() throws {
        try FileManagerPlayground {
            Directory("src") {
                Directory("contents") {
                    File(
                        "index.yml",
                        string: """
                            baseUrl: http://localhost:8080/
                            name: Test
                            """
                    )
                }
            }
        }
        .test {
            let url = $1.appending(path: "src/contents/")
            let loader = SettingsLoader(
                url: url,
                locations: [
                    "index.yml"
                ],
                encoder: ToucanYAMLEncoder(),
                decoder: ToucanYAMLDecoder(),
                logger: .init(label: "SettingsLoaderTestSuite")
            )
            let result = try loader.load()

            #expect(
                result
                    == Settings(
                        baseUrl: "http://localhost:8080/",
                        name: "Test",
                        locale: nil,
                        timeZone: nil,
                        userDefined: [:]
                    )
            )
        }
    }
}
