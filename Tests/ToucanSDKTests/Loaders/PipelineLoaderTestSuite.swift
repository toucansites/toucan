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
struct PipelineLoaderTestSuite {
    
    @Test
    func basicLoad() throws {
        let logger = Logger(label: "PipelineLoaderTestSuite")
        try FileManagerPlayground {
            Directory("src") {
                Directory("pipelines") {
                    File(
                        "404.yml",
                        string: """
                        id: not-found
                        contentTypes: 
                            include:
                                - "not-found"
                        engine: 
                            id: mustache
                            options:
                                contentTypes: 
                                    not-found:
                                        template: "pages.404"
                        output:
                            path: ""
                            file: 404
                            ext: html
                        """
                    )
                    File(
                        "redirect.yml",
                        string: """
                        id: redirect
                        contentTypes: 
                            include:
                                - redirect
                        engine: 
                            id: mustache
                            options:
                                contentTypes: 
                                    redirect:
                                        template: "redirect"
                        output:
                            path: "{{slug}}"
                            file: index
                            ext: html
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
            let loader = ConfigLoaderTestSuite.getConfigLoader(url: sourceUrl, logger: logger)
            let config = try loader.load()
            
            let sourceConfig = SourceConfig(sourceUrl: sourceUrl, config: config)
            
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
        }
        
    }

}
