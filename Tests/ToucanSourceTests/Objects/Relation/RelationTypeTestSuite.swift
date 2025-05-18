//
//  RelationTypeTestSuite.swift
//  Toucan
//
//  Created by Binary Birds on 2025. 05. 18..

import Foundation
import Testing
import ToucanSerialization

@testable import ToucanSource

@Suite
struct RelationTypeTestSuite {

    @Test
    func basics() throws {
        let object = [RelationType.one, RelationType.many]
        let encoder = ToucanYAMLEncoder()
        let decoder = ToucanYAMLDecoder()

        let value1: String = try encoder.encode(object)
        let result1 = try decoder.decode([RelationType].self, from: value1)

        let value2: Data = try encoder.encode(object)
        let result2 = try decoder.decode([RelationType].self, from: value2)

        #expect(object == result1)
        #expect(object == result2)
    }

    @Test
    func one() throws {
        let value = "one"
        let decoder = ToucanYAMLDecoder()
        let result = try decoder.decode(RelationType.self, from: value)
        let expectation = RelationType.one

        #expect(result == expectation)
    }

    @Test
    func many() throws {
        let value = "many"
        let decoder = ToucanYAMLDecoder()
        let result = try decoder.decode(RelationType.self, from: value)
        let expectation = RelationType.many

        #expect(result == expectation)
    }
}
