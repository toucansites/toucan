//
//  ConditionTestSuite.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 05. 18..
//

import Foundation
import Testing
import ToucanSerialization

@testable import ToucanSource

@Suite
struct ConditionTestSuite {
    @Test
    func fieldBasics() throws {
        let object = Condition.field(
            key: "foo",
            operator: .equals,
            value: "a"
        )

        let encoder = ToucanYAMLEncoder()
        let decoder = ToucanYAMLDecoder()

        let value1: String = try encoder.encode(object)
        let result1 = try decoder.decode(Condition.self, from: value1)

        let value2: Data = try encoder.encode(object)
        let result2 = try decoder.decode(Condition.self, from: value2)

        #expect(object == result1)
        #expect(object == result2)
    }

    @Test
    func andBasics() throws {
        let object = Condition.and(
            [
                .field(
                    key: "foo",
                    operator: .equals,
                    value: "a"
                ),
                .field(
                    key: "bar",
                    operator: .notEquals,
                    value: "b"
                ),
            ]
        )

        let encoder = ToucanYAMLEncoder()
        let decoder = ToucanYAMLDecoder()

        let value1: String = try encoder.encode(object)
        let result1 = try decoder.decode(Condition.self, from: value1)

        let value2: Data = try encoder.encode(object)
        let result2 = try decoder.decode(Condition.self, from: value2)

        #expect(object == result1)
        #expect(object == result2)
    }

    @Test
    func orBasics() throws {
        let object = Condition.or(
            [
                .field(
                    key: "foo",
                    operator: .equals,
                    value: "a"
                ),
                .field(
                    key: "bar",
                    operator: .notEquals,
                    value: "b"
                ),
            ]
        )

        let encoder = ToucanYAMLEncoder()
        let decoder = ToucanYAMLDecoder()

        let value1: String = try encoder.encode(object)
        let result1 = try decoder.decode(Condition.self, from: value1)

        let value2: Data = try encoder.encode(object)
        let result2 = try decoder.decode(Condition.self, from: value2)

        #expect(object == result1)
        #expect(object == result2)
    }

    @Test
    func customField() throws {
        let value = """
            key: foo
            operator: equals
            value: a
            """ + "\n"

        let encoder = ToucanYAMLEncoder()
        let decoder = ToucanYAMLDecoder()
        let result = try decoder.decode(Condition.self, from: value)

        let expectation = Condition.field(
            key: "foo",
            operator: .equals,
            value: "a"
        )

        let encodedValue: String = try encoder.encode(expectation)

        #expect(result == expectation)
        #expect(value == encodedValue)
    }

    @Test
    func customAnd() throws {
        let value = """
            and:
            - key: foo
              operator: equals
              value: a
            - key: bar
              operator: notEquals
              value: b
            """ + "\n"

        let encoder = ToucanYAMLEncoder()
        let decoder = ToucanYAMLDecoder()
        let result = try decoder.decode(Condition.self, from: value)

        let expectation = Condition.and(
            [
                .field(
                    key: "foo",
                    operator: .equals,
                    value: "a"
                ),
                .field(
                    key: "bar",
                    operator: .notEquals,
                    value: "b"
                ),
            ]
        )

        let encodedValue: String = try encoder.encode(expectation)

        #expect(result == expectation)
        #expect(value == encodedValue)
    }

    @Test
    func customOr() throws {
        let value = """
            or:
            - key: foo
              operator: equals
              value: a
            - key: bar
              operator: notEquals
              value: b
            """ + "\n"

        let encoder = ToucanYAMLEncoder()
        let decoder = ToucanYAMLDecoder()
        let result = try decoder.decode(Condition.self, from: value)

        let expectation = Condition.or(
            [
                .field(
                    key: "foo",
                    operator: .equals,
                    value: "a"
                ),
                .field(
                    key: "bar",
                    operator: .notEquals,
                    value: "b"
                ),
            ]
        )

        let encodedValue: String = try encoder.encode(expectation)

        #expect(result == expectation)
        #expect(value == encodedValue)
    }

    @Test
    func stringValue() throws {
        let data = """
            key: name
            operator: equals
            value: hello
            """

        let decoder = ToucanYAMLDecoder()

        let result = try decoder.decode(
            Condition.self,
            from: data
        )

        guard case let .field(key, op, value) = result else {
            Issue.record("Result is not a field case.")
            return
        }

        #expect(key == "name")
        #expect(op == .equals)
        #expect(value.value(as: String.self) == "hello")
    }

    @Test
    func arrayValue() throws {
        let data = """
            key: name
            operator: in
            value: 
                - foo
                - bar
                - baz
            """

        let decoder = ToucanYAMLDecoder()

        let result = try decoder.decode(
            Condition.self,
            from: data
        )

        guard case let .field(key, op, value) = result else {
            Issue.record("Result is not a field case.")
            return
        }

        #expect(key == "name")
        #expect(op == .in)
        #expect(value.value(as: [String].self) == ["foo", "bar", "baz"])
    }

    @Test
    func orConditionValues() throws {
        let data = """
            or:
                - key: name
                  operator: equals
                  value: hello

                - key: description
                  operator: like
                  value: foo
            """

        let decoder = ToucanYAMLDecoder()

        let result = try decoder.decode(
            Condition.self,
            from: data
        )

        guard case let .or(conditions) = result else {
            Issue.record("Result is not an and case.")
            return
        }

        try #require(conditions.count == 2)

        guard case let .field(key, op, value) = conditions[0] else {
            Issue.record("Condition is not a field case.")
            return
        }

        #expect(key == "name")
        #expect(op == .equals)
        #expect(value.value(as: String.self) == "hello")

        guard case let .field(key, op, value) = conditions[1] else {
            Issue.record("Condition is not a field case.")
            return
        }

        #expect(key == "description")
        #expect(op == .like)
        #expect(value.value(as: String.self) == "foo")
    }

    @Test
    func complexCondition() throws {
        let data = """
            or:
                - key: name
                  operator: equals
                  value: hello

                - and: 
                    - key: featured
                      operator: equals
                      value: false

                    - key: likes
                      operator: greaterThan
                      value: 100
            """

        let decoder = ToucanYAMLDecoder()

        let result = try decoder.decode(
            Condition.self,
            from: data
        )

        guard case let .or(conditions) = result else {
            Issue.record("Result is not an and case.")
            return
        }

        try #require(conditions.count == 2)

        guard case let .field(key, op, value) = conditions[0] else {
            Issue.record("Condition is not a field case.")
            return
        }

        #expect(key == "name")
        #expect(op == .equals)
        #expect(value.value(as: String.self) == "hello")

        guard case let .and(subconditions) = conditions[1] else {
            Issue.record("Result is not an and case.")
            return
        }

        guard case let .field(key, op, value) = subconditions[0] else {
            Issue.record("Condition is not a field case.")
            return
        }

        #expect(key == "featured")
        #expect(op == .equals)
        #expect(value.value(as: Bool.self) == false)

        guard case let .field(key, op, value) = subconditions[1] else {
            Issue.record("Condition is not a field case.")
            return
        }

        #expect(key == "likes")
        #expect(op == .greaterThan)
        #expect(value.value(as: Int.self) == 100)
    }

    @Test
    func wrongCondition() throws {
        let data = """
            wrong:
                - key: name
                  operator: equals
                  value: hello
            """

        let decoder = ToucanYAMLDecoder()
        do {
            _ = try decoder.decode(
                Condition.self,
                from: data
            )
        }
        catch {
            #expect(
                error.localizedDescription.contains(
                    "ToucanDecoderError"
                )
            )
        }
    }
}
