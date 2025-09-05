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

    @Test
    func minimal() throws {
        let data = """
            id: test
            engine: 
                id: engine
            output:
                path: path
                file: file
                ext: ext
            """
            .data(using: .utf8)!

        let decoder = ToucanYAMLDecoder()

        let result = try decoder.decode(
            Pipeline.self,
            from: data
        )

        #expect(result.id == "test")
        #expect(result.engine.id == "engine")
        #expect(result.output.path == "path")
        #expect(result.output.file == "file")
        #expect(result.output.ext == "ext")
    }

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
        let defaultScope = try #require(
            result.scopes[Pipeline.Scope.Keys.wildcard.rawValue]
        )
        let defaultReferenceScope = try #require(
            defaultScope[Pipeline.Scope.Context.Keys.reference.rawValue]
        )
        let defaultListScope = try #require(
            defaultScope[Pipeline.Scope.Context.Keys.list.rawValue]
        )
        let defaultDetailScope = try #require(
            defaultScope[Pipeline.Scope.Context.Keys.detail.rawValue]
        )
        #expect(defaultReferenceScope.context == .reference)
        #expect(defaultListScope.context == .list)
        #expect(defaultDetailScope.context == .detail)
        let postScope = try #require(result.scopes["post"])
        let postListScope = try #require(
            postScope[Pipeline.Scope.Keys.list.rawValue]
        )
        #expect(postListScope.context == .detail)
    }

    @Test
    func assets() throws {
        let data = """
            id: test
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
            engine: 
                id: engine
            output:
                path: path
                file: file
                ext: ext
            """
            .data(using: .utf8)!

        let decoder = ToucanYAMLDecoder()

        let result = try decoder.decode(
            Pipeline.self,
            from: data
        )

        #expect(result.assets.behaviors.isEmpty)
        #expect(result.assets.properties.count == 4)
        #expect(result.assets.properties[0].action == .add)
        #expect(result.assets.properties[1].action == .set)
        #expect(result.assets.properties[2].action == .load)
        #expect(result.assets.properties[3].action == .parse)
    }
}
