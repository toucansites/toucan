//
//  OperatorTestSuite.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 05. 18..
//

import Foundation
import Testing
import ToucanSerialization

@testable import ToucanSource

@Suite
struct OperatorTestSuite {

    @Test
    func basics() throws {
        let object = Operator.allCases

        let encoder = ToucanYAMLEncoder()
        let decoder = ToucanYAMLDecoder()

        let value1: String = try encoder.encode(object)
        let result1 = try decoder.decode([Operator].self, from: value1)

        let value2: Data = try encoder.encode(object)
        let result2 = try decoder.decode([Operator].self, from: value2)

        #expect(object == result1)
        #expect(object == result2)

    }

    @Test
    func equals() throws {
        let value = "equals"
        let decoder = ToucanYAMLDecoder()
        let result = try decoder.decode(Operator.self, from: value)
        let expectation = Operator.equals

        #expect(result == expectation)
    }

    @Test
    func notEquals() throws {
        let value = "notEquals"
        let decoder = ToucanYAMLDecoder()
        let result = try decoder.decode(Operator.self, from: value)
        let expectation = Operator.notEquals

        #expect(result == expectation)
    }

    @Test
    func lessThan() throws {
        let value = "lessThan"
        let decoder = ToucanYAMLDecoder()
        let result = try decoder.decode(Operator.self, from: value)
        let expectation = Operator.lessThan

        #expect(result == expectation)
    }

    @Test
    func lessThanOrEquals() throws {
        let value = "lessThanOrEquals"
        let decoder = ToucanYAMLDecoder()
        let result = try decoder.decode(Operator.self, from: value)
        let expectation = Operator.lessThanOrEquals

        #expect(result == expectation)
    }

    @Test
    func greaterThan() throws {
        let value = "greaterThan"
        let decoder = ToucanYAMLDecoder()
        let result = try decoder.decode(Operator.self, from: value)
        let expectation = Operator.greaterThan

        #expect(result == expectation)
    }

    @Test
    func greaterThanOrEquals() throws {
        let value = "greaterThanOrEquals"
        let decoder = ToucanYAMLDecoder()
        let result = try decoder.decode(Operator.self, from: value)
        let expectation = Operator.greaterThanOrEquals

        #expect(result == expectation)
    }

    @Test
    func like() throws {
        let value = "like"
        let decoder = ToucanYAMLDecoder()
        let result = try decoder.decode(Operator.self, from: value)
        let expectation = Operator.like

        #expect(result == expectation)
    }

    @Test
    func caseInsensitiveLike() throws {
        let value = "caseInsensitiveLike"
        let decoder = ToucanYAMLDecoder()
        let result = try decoder.decode(Operator.self, from: value)
        let expectation = Operator.caseInsensitiveLike

        #expect(result == expectation)
    }

    @Test
    func `in`() throws {
        let value = "in"
        let decoder = ToucanYAMLDecoder()
        let result = try decoder.decode(Operator.self, from: value)
        let expectation = Operator.in

        #expect(result == expectation)
    }

    @Test
    func contains() throws {
        let value = "contains"
        let decoder = ToucanYAMLDecoder()
        let result = try decoder.decode(Operator.self, from: value)
        let expectation = Operator.contains

        #expect(result == expectation)
    }

    @Test
    func matching() throws {
        let value = "matching"
        let decoder = ToucanYAMLDecoder()
        let result = try decoder.decode(Operator.self, from: value)
        let expectation = Operator.matching

        #expect(result == expectation)
    }

}
