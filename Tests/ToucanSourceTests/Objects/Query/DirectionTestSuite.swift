//
//  DirectionTestSuite.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 05. 18..
//

import Foundation
import Testing
import ToucanSerialization

@testable import ToucanSource

@Suite
struct DirectionTestSuite {

    @Test
    func basics() throws {
        let object = Direction.allCases

        let encoder = ToucanYAMLEncoder()
        let decoder = ToucanYAMLDecoder()

        let value1: String = try encoder.encode(object)
        let result1 = try decoder.decode([Direction].self, from: value1)

        let value2: Data = try encoder.encode(object)
        let result2 = try decoder.decode([Direction].self, from: value2)

        #expect(object == result1)
        #expect(object == result2)

    }

    @Test
    func defaults() throws {
        let object = Direction.defaults
        #expect(object == .asc)
    }

    @Test
    func ascending() throws {
        let value = "asc"
        let decoder = ToucanYAMLDecoder()
        let result = try decoder.decode(Direction.self, from: value)
        let expectation = Direction.asc

        #expect(result == expectation)
    }

    @Test
    func descending() throws {
        let value = "desc"
        let decoder = ToucanYAMLDecoder()
        let result = try decoder.decode(Direction.self, from: value)
        let expectation = Direction.desc

        #expect(result == expectation)
    }
}
