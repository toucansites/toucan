//
//  PipelineTestSuite.swift
//  Toucan
//
//  Created by Binary Birds on 2025. 03. 30..

import Foundation
import Testing
import ToucanSerialization

@testable import ToucanSource

@Suite
struct PipelineTestSuite {
    // MARK: - order

    @Test
    func standard() throws {
        let data = """
            id: test
            queries: 
                featured:
                    contentType: post
                    limit: 10
                    filter:
                        key: featured
                        operator: equals
                        value: true
                    orderBy:
                        - key: publication
                          direction: desc

            contentTypes: 
                include:
                    - page
                    - post
            engine: 
                id: test
                options:
                    foo: bar
                    foo2: 
                    bool: false
                    double: 2.0
                    int: 100
                    date: 01/16/2023
                    array:
                        - value1
                        - value2
            output:
                path: "{{slug}}"
                file: "{{id}}"
                ext: json
            """
            .data(using: .utf8)!

        let decoder = ToucanYAMLDecoder()

        let result = try decoder.decode(
            Pipeline.self,
            from: data
        )

        #expect(result.contentTypes.include == ["page", "post"])
        let query = try #require(result.queries["featured"])
        #expect(query.contentType == "post")
        #expect(result.engine.id == "test")
        #expect(result.engine.options.string("") == nil)
        #expect(result.engine.options.string("foo") == "bar")
        #expect(result.engine.options.string("foo.foo2") == nil)
        #expect(
            result.engine.options.string("foo4", allowingEmptyValue: true)
                == nil
        )
        #expect(result.engine.options.string("foo4") == nil)
        #expect(result.engine.options.bool("bool") == false)
        #expect(result.engine.options.double("double") == 2.0)
        #expect(result.engine.options.int("int") == 100)

        let formatter = DateFormatter()
        formatter.locale = .init(identifier: "en-US")
        formatter.timeZone = .init(secondsFromGMT: 0)!

        formatter.dateFormat = "MM/dd/yyyy"
        #expect(
            result.engine.options.date("date", formatter: formatter)?
                .formatted(.iso8601) == "2023-01-16T00:00:00Z"
        )
        #expect(
            result.engine.options.date("date2", formatter: formatter)?
                .formatted() == nil
        )
        #expect(
            result.engine.options.array("array", as: String.self) == [
                "value1", "value2",
            ]
        )
        #expect(result.engine.options.array("array", as: Int.self) == [])
    }

    @Test
    func scopes() throws {
        let data = """
            id: test
            scopes: 
                post:
                    list:
                        context: 
                            - detail
                        fields:
            dataTypes:
                date:
                    dateFormats:
                        test: 
                            locale: en-US
                            timeZone: EST
                            format: ymd
            engine: 
                id: test
            output:
                path: "{{slug}}"
                file: index
                ext: html
            """
            .data(using: .utf8)!

        let decoder = ToucanYAMLDecoder()

        let result = try decoder.decode(
            Pipeline.self,
            from: data
        )

        #expect(result.contentTypes.include.isEmpty)
        #expect(result.engine.id == "test")

        //        let defaultScope = try #require(result.scopes["*"])
        //        let defaultReferenceScope = try #require(defaultScope["reference"])
        //        let defaultListScope = try #require(defaultScope["list"])
        //        let defaultDetailScope = try #require(defaultScope["detail"])        //        #expect(defaultReferenceScope.context == .reference)
        //        #expect(defaultListScope.context == .list)
        //        #expect(defaultDetailScope.context == .detail)        //        let dateFormat = try #require(result.dataTypes.date.dateFormats["test"])
        //        #expect(
        //            dateFormat
        //                == .init(
        //                    locale: "en-US",
        //                    timeZone: "EST",
        //                    format: "ymd"
        //                )
        //        )        //        let postScope = try #require(result.scopes["post"])
        //        let postListScope = try #require(postScope["list"])
        //        #expect(postListScope.context == .detail)
    }

    // MARK: - pipelines

    //    @Test
    //    func basicLoad() throws {
    //        let logger = Logger(label: "PipelineLoaderTestSuite")
    //        try FileManagerPlayground {
    //            Directory(name: "src") {
    //                Directory(name: "pipelines") {
    //                    pipeline404(addTransformers: true)
    //                    pipelineRedirect()
    //                }
    //                File(
    //                    "config.yml",
    //                    string: """
    //                        pipelines:
    //                            path: pipelines
    //                        """
    //                )
    //            }
    //        }
    //        .test {
    //            let sourceURL = $1.appending(path: "src")
    //            let loader = ConfigLoaderTestSuite.getConfigLoader(
    //                url: sourceURL,
    //                logger: logger
    //            )
    //            let config = try loader.load(Config.self)    //            let sourceConfig = SourceConfig(
    //                sourceUrl: sourceURL,
    //                config: config
    //            )    //            let fs = ToucanFileSystem(fileManager: $0)
    //            let pipelineLocations = fs.pipelineLocator.locate(
    //                at: sourceConfig.pipelinesURL
    //            )
    //            let pipelineLoader = PipelineLoader(
    //                url: sourceConfig.pipelinesURL,
    //                locations: pipelineLocations,
    //                decoder: ToucanYAMLDecoder(),
    //                logger: logger
    //            )
    //            let pipelines = try pipelineLoader.load()
    //            #expect(pipelines.count == 2)
    //            #expect(pipelines[1].transformers.count == 2)
    //        }    //    }    //    @Test
    //    func loadAssets() throws {
    //        let logger = Logger(label: "PipelineLoaderTestSuite")
    //        try FileManagerPlayground {
    //            Directory(name: "src") {
    //                Directory(name: "pipelines") {
    //                    pipelineSitemap(
    //                        """
    //                        assets:
    //                          properties:
    //                            - action: add
    //                              property: js
    //                              resolvePath: false
    //                              input:
    //                                name: main
    //                                ext: js
    //                            - action: set
    //                              property: image
    //                              resolvePath: true
    //                              input:
    //                                name: cover
    //                                ext: jpg
    //                            - action: load
    //                              property: svgs
    //                              resolvePath: false
    //                              input:
    //                                name: "*"
    //                                ext: svg
    //                            - action: parse
    //                              property: data
    //                              resolvePath: false
    //                              input:
    //                                name: "*"
    //                                ext: json
    //                        """
    //                    )
    //                }
    //                File(
    //                    "config.yml",
    //                    string: """
    //                        pipelines:
    //                            path: pipelines
    //                        """
    //                )
    //            }
    //        }
    //        .test {
    //            let sourceURL = $1.appending(path: "src")
    //            let loader = ConfigLoaderTestSuite.getConfigLoader(
    //                url: sourceURL,
    //                logger: logger
    //            )
    //            let config = try loader.load(Config.self)    //            let sourceConfig = SourceConfig(
    //                sourceUrl: sourceURL,
    //                config: config
    //            )    //            let fs = ToucanFileSystem(fileManager: $0)
    //            let pipelineLocations = fs.pipelineLocator.locate(
    //                at: sourceConfig.pipelinesURL
    //            )
    //            let pipelineLoader = PipelineLoader(
    //                url: sourceConfig.pipelinesURL,
    //                locations: pipelineLocations,
    //                decoder: ToucanYAMLDecoder(),
    //                logger: logger
    //            )
    //            let pipelines = try pipelineLoader.load()
    //            #expect(pipelines.count == 1)
    //            #expect(pipelines[0].assets.properties.count == 4)
    //            #expect(pipelines[0].assets.properties[0].action == .add)
    //            #expect(pipelines[0].assets.properties[1].action == .set)
    //            #expect(pipelines[0].assets.properties[2].action == .load)
    //            #expect(pipelines[0].assets.properties[3].action == .parse)
    //        }
    //    }
}
