//
//  ConfigLoaderTestSuite.swift
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

@Suite
struct ConfigLoaderTestSuite {

    static func getDefaultResult() -> Config {
        .defaults
    }

    static func getConfigLoader(
        url: URL,
        logger: Logger
    ) -> CombinedYAMLLoader {
        CombinedYAMLLoader(
            url: url,
            locations: FileManager.default.find(
                name: "config",
                extensions: ["yaml", "yml"],
                at: url
            ),
            encoder: ToucanYAMLEncoder(),
            decoder: ToucanYAMLDecoder(),
            logger: logger
        )
    }

    @Test
    func testWithNoDefaultValue() throws {
        let logger = Logger(label: "ConfigLoaderTestSuite")
        try FileManagerPlayground {
            Directory("src") {
                File(
                    "config.yml",
                    string: """
                        pipelines:
                            path: pipelinesNotDefault
                        contents:
                            path: contentsNotDefault
                            assets: 
                                path: assetsNotDefault
                        types:
                            path: typesNotDefault
                        blocks:
                            path: blocksNotDefault
                        themes:
                            location:
                                path: themesNotDefault
                            current:
                                path: defaultNotDefault
                            assets:
                                path: assetsNotDefault
                            templates:
                                path: templatesNotDefault
                            overrides:
                                path: overridesNotDefault
                        dateFormats:
                            input: 
                                format: y
                            output:
                                hu:
                                    locale: hu-HU
                                    timeZone: CET
                                    format: "y.MM.dd"
                        renderer:
                            wordsPerMinute: 240
                            outlineLevels:
                                - 3
                                - 4
                            paragraphStyles:
                                note: 
                                    - noteNotDefault
                                warn:
                                    - warnNotDefault
                                    - warningNotDefault
                                tip:
                                    - tipNotDefault
                                important:
                                    - importantNotDefault
                                error:
                                    - errorNotDefault
                                    - cautionNotDefault
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

            #expect(
                result
                    == Config(
                        site: .defaults,
                        pipelines: .init(path: "pipelinesNotDefault"),
                        contents: .init(
                            path: "contentsNotDefault",
                            assets: .init(path: "assetsNotDefault")
                        ),
                        types: .init(path: "typesNotDefault"),
                        blocks: .init(path: "blocksNotDefault"),
                        themes: .init(
                            location: .init(path: "themesNotDefault"),
                            current: .init(path: "defaultNotDefault"),
                            assets: .init(path: "assetsNotDefault"),
                            templates: .init(path: "templatesNotDefault"),
                            overrides: .init(path: "overridesNotDefault")
                        ),
                        dateFormats: .init(
                            input: .init(format: "y"),
                            output: [
                                "hu": .init(
                                    locale: "hu-HU",
                                    timeZone: "CET",
                                    format: "y.MM.dd"
                                )
                            ]
                        ),
                        renderer: .init(
                            wordsPerMinute: 240,
                            outlineLevels: [3, 4],
                            paragraphStyles: .init(
                                styles: [
                                    "note": ["noteNotDefault"],
                                    "warn": [
                                        "warnNotDefault", "warningNotDefault",
                                    ],
                                    "tip": ["tipNotDefault"],
                                    "important": ["importantNotDefault"],
                                    "error": [
                                        "errorNotDefault", "cautionNotDefault",
                                    ],
                                ]
                            )
                        )
                    )
            )
        }
    }

}
