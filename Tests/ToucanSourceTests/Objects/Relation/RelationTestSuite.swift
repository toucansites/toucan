//
//  RelationTestSuite.swift
//  Toucan
//
//  Created by Binary Birds on 2025. 03. 12..

import Foundation
import Testing
import ToucanSerialization

@testable import ToucanSource

@Suite
struct RelationTestSuite {

    @Test
    func basicOrdering() throws {
        let data = """
            references: post
            type: many
            order: 
                key: title
                direction: desc
            """
            .data(using: .utf8)!

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
