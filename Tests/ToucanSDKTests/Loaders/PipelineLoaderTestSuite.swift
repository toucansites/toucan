//
//  PipelineLoaderTestSuite.swift
//  Toucan
//
//  Created by gerp83 on 2025. 04. 08..
//

import Foundation
import Testing
import ToucanModels
import ToucanTesting
import Logging
import FileManagerKitTesting
@testable import ToucanSource
@testable import ToucanSDK
@testable import ToucanFileSystem

@Suite
struct PipelineLoaderTestSuite: PipelineTestSuite {

    @Test
    func basicLoad() throws {
        let logger = Logger(label: "PipelineLoaderTestSuite")
        try FileManagerPlayground {
            Directory("src") {
                Directory("pipelines") {
                    pipeline404(addTransformers: true)
                    pipelineRedirect()
                }
                File(
                    "config.yml",
                    string: """
                        pipelines:
                            path: pipelines
                        """
                )
            }
        }
        .test {
            let sourceUrl = $1.appending(path: "src")
            let loader = ConfigLoaderTestSuite.getConfigLoader(
                url: sourceUrl,
                logger: logger
            )
            let config = try loader.load()

            let sourceConfig = SourceConfig(
                sourceUrl: sourceUrl,
                config: config
            )

            let fs = ToucanFileSystem(fileManager: $0)
            let pipelineLocations = fs.pipelineLocator.locate(
                at: sourceConfig.pipelinesUrl
            )
            let pipelineLoader = PipelineLoader(
                url: sourceConfig.pipelinesUrl,
                locations: pipelineLocations,
                decoder: ToucanYAMLDecoder(),
                logger: logger
            )
            let pipelines = try pipelineLoader.load()
            #expect(pipelines.count == 2)
            #expect(pipelines[1].transformers.count == 2)
        }

    }

    @Test
    func loadAssets() throws {
        let logger = Logger(label: "PipelineLoaderTestSuite")
        try FileManagerPlayground {
            Directory("src") {
                Directory("pipelines") {
                    pipelineSitemap(
                        """
                        assets:
                          properties:
                            - action: add
                              property: js
                              resolvePath: false
                              input:
                                name: main
                                ext: js
                            - action: set
                              property: image
                              resolvePath: true
                              input:
                                name: cover
                                ext: jpg
                            - action: load
                              property: svgs
                              resolvePath: false
                              input:
                                name: "*"
                                ext: svg
                            - action: parse
                              property: data
                              resolvePath: false
                              input:
                                name: "*"
                                ext: json
                        """
                    )
                }
                File(
                    "config.yml",
                    string: """
                        pipelines:
                            path: pipelines
                        """
                )
            }
        }
        .test {
            let sourceUrl = $1.appending(path: "src")
            let loader = ConfigLoaderTestSuite.getConfigLoader(
                url: sourceUrl,
                logger: logger
            )
            let config = try loader.load()

            let sourceConfig = SourceConfig(
                sourceUrl: sourceUrl,
                config: config
            )

            let fs = ToucanFileSystem(fileManager: $0)
            let pipelineLocations = fs.pipelineLocator.locate(
                at: sourceConfig.pipelinesUrl
            )
            let pipelineLoader = PipelineLoader(
                url: sourceConfig.pipelinesUrl,
                locations: pipelineLocations,
                decoder: ToucanYAMLDecoder(),
                logger: logger
            )
            let pipelines = try pipelineLoader.load()
            #expect(pipelines.count == 1)
            #expect(pipelines[0].assets.properties.count == 4)
            #expect(pipelines[0].assets.properties[0].action == .add)
            #expect(pipelines[0].assets.properties[1].action == .set)
            #expect(pipelines[0].assets.properties[2].action == .load)
            #expect(pipelines[0].assets.properties[3].action == .parse)
        }
    }

}
