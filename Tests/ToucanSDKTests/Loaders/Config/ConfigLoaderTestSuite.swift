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
struct ConfigLoaderTestSuite {

    static func getDefaultResult() -> Config {
        return Config(
            pipelines: .defaults,
            contents: .defaults,
            themes: .defaults,
            dateFormats: .defaults,
            renderer: .defaults
        )
    }

    static func getConfigLoader(url: URL, logger: Logger) -> ConfigLoader {
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
                        themes:
                            location:
                                path: themesNotDefault
                            current:
                                path: defaultNotDefault
                            assets:
                                path: assetsNotDefault
                            templates:
                                path: templatesNotDefault
                            types:
                                path: typesNotDefault
                            overrides:
                                path: overridesNotDefault
                            blocks:
                                path: blocksNotDefault
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
            let result = try loader.load()

            #expect(
                result
                    == Config(
                        pipelines: .init(path: "pipelinesNotDefault"),
                        contents: .init(
                            path: "contentsNotDefault",
                            assets: .init(path: "assetsNotDefault")
                        ),
                        themes: .init(
                            location: .init(path: "themesNotDefault"),
                            current: .init(path: "defaultNotDefault"),
                            assets: .init(path: "assetsNotDefault"),
                            templates: .init(path: "templatesNotDefault"),
                            types: .init(path: "typesNotDefault"),
                            overrides: .init(path: "overridesNotDefault"),
                            blocks: .init(path: "blocksNotDefault")
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
                                note: ["noteNotDefault"],
                                warn: ["warnNotDefault", "warningNotDefault"],
                                tip: ["tipNotDefault"],
                                important: ["importantNotDefault"],
                                error: ["errorNotDefault", "cautionNotDefault"]
                            )
                        )
                    )
            )
        }
    }

}
