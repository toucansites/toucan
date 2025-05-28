//
//  TypesTestSuite.swift
//  Toucan
//
//  Created by Binary Birds on 2025. 03. 30..

import Foundation
import Testing
import ToucanSerialization

@testable import ToucanSource

@Suite
struct TypesTestSuite {

    // MARK: - order

    @Test
    func minimal() throws {
        let data = """
            id: post
            """

        let decoder = ToucanYAMLDecoder()
        let result = try decoder.decode(ContentDefinition.self, from: data)

        #expect(result.id == "post")
    }

    @Test
    func complex() throws {
        let data = """
            id: post
            properties: 
                title: 
                    type: string
                publication:
                    type: date
                    config: 
                        format: "y.m.d"
                    required: true
            relations:
                authors:
                    references: author
                    type: many
                    order: 
                        key: name
                tags:
                    references: tag
                    type: many
                    order: 
                        key: priority
                        sort: desc
            queries:
                prev:
                    contentType: post
                    limit: 1
                    filter:
                        key: publication
                        operator: lessThan
                        value: "{{publication}}"
                    orderBy:
                        - key: publication
                          direction: desc

                next:
                    contentType: post
                    limit: 1
                    filter:
                        key: publication
                        operator: greaterThan
                        value: "{{publication}}"
                    orderBy:
                        - key: publication
                          direction: asc

                related:
                    contentType: post
                    limit: 4
                    filter:
                        and:
                            - key: authors
                              operator: matching
                              value: "{{authors}}"
                            
                            - key: id
                              operator: notEquals
                              value: "{{id}}"

                similar:
                    contentType: post
                    limit: 4
                    filter:
                        and:
                            - key: tags
                              operator: matching
                              value: "{{tags}}"
                            
                            - key: id
                              operator: notEquals
                              value: "{{id}}"

                
            """

        let decoder = ToucanYAMLDecoder()
        let result = try decoder.decode(ContentDefinition.self, from: data)

        #expect(result.id == "post")
    }
}
