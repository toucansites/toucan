//
//  RelationDecodingTestSuite.swift
//  Toucan
//
//  Created by Binary Birds on 2025. 03. 12..

import Foundation
import Testing
import ToucanSource
import ToucanModels

@Suite
struct RelationDecodingTestSuite {

    // MARK: - order

    @Test
    func basicOrdering() throws {
        let data = """
            references: post
            type: many
            order: 
                key: title
                direction: desc
            """
            .dataValue()

        let decoder = ToucanYAMLDecoder()

        let result = try decoder.decode(
            Relation.self,
            from: data
        )

        #expect(result.references == "post")
        #expect(result.type == .many)
        #expect(result.order?.key == "title")
        #expect(result.order?.direction == .desc)
    }
}
