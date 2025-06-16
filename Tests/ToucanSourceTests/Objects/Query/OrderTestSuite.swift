//
//  OrderTestSuite.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 05. 18..
//

import Foundation
import Testing
import ToucanSerialization

@testable import ToucanSource

@Suite
struct OrderTestSuite {
    @Test
    func basics() throws {
        let object = Order(key: "foo")
        let encoder = ToucanYAMLEncoder()
        let decoder = ToucanYAMLDecoder()

        let value1: String = try encoder.encode(object)
        let result1 = try decoder.decode(Order.self, from: value1)

        let value2: Data = try encoder.encode(object)
        let result2 = try decoder.decode(Order.self, from: value2)

        #expect(object == result1)
        #expect(object == result2)
    }

    @Test
    func defaults() throws {
        let value = """
        key: foo
        """
        let decoder = ToucanYAMLDecoder()
        let result = try decoder.decode(Order.self, from: value)
        let expectation = Order(key: "foo")

        #expect(result == expectation)
    }

    @Test
    func custom() throws {
        let value = """
        direction: desc
        key: foo
        """ + "\n"

        let encoder = ToucanYAMLEncoder()
        let decoder = ToucanYAMLDecoder()
        let result = try decoder.decode(Order.self, from: value)

        let expectation = Order(key: "foo", direction: .desc)
        let encodedValue: String = try encoder.encode(expectation)

        #expect(result == expectation)
        #expect(value == encodedValue)
    }
}
