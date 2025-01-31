import Foundation
import Testing
import ToucanSource
@testable import ToucanModels

@Suite
struct QueryDecodingTestSuite {

    // MARK: -

    @Test
    func simpleCondition() throws {

        let data = """
            key: name
            operator: equals
            value: hello
            """
            .data(using: .utf8)!

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
        #expect(value as? String == "hello")
    }

    @Test
    func arrayCondition() throws {

        let data = """
            key: name
            operator: in
            value: 
                - foo
                - bar
                - baz
            """
            .data(using: .utf8)!

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
        #expect(value as? [String] == ["foo", "bar", "baz"])
    }

    @Test
    func andCondition() throws {

        let data = """
            and:
                - key: name
                  operator: equals
                  value: hello
            """
            .data(using: .utf8)!

        let decoder = ToucanYAMLDecoder()

        let result = try decoder.decode(
            Condition.self,
            from: data
        )

        guard case let .and(conditions) = result else {
            Issue.record("Result is not an and case.")
            return
        }

        try #require(conditions.count == 1)

        guard case let .field(key, op, value) = conditions[0] else {
            Issue.record("Condition is not a field case.")
            return
        }

        #expect(key == "name")
        #expect(op == .equals)
        #expect(value as? String == "hello")
    }

    @Test
    func orCondition() throws {

        let data = """
            or:
                - key: name
                  operator: equals
                  value: hello
                
                - key: description
                  operator: like
                  value: foo
            """
            .data(using: .utf8)!

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
        #expect(value as? String == "hello")

        guard case let .field(key, op, value) = conditions[1] else {
            Issue.record("Condition is not a field case.")
            return
        }

        #expect(key == "description")
        #expect(op == .like)
        #expect(value as? String == "foo")
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
                      operator: greater-than
                      value: 100
            """
            .data(using: .utf8)!

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
        #expect(value as? String == "hello")

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
        #expect(value as? Bool == false)

        guard case let .field(key, op, value) = subconditions[1] else {
            Issue.record("Condition is not a field case.")
            return
        }

        #expect(key == "likes")
        #expect(op == .greaterThan)
        #expect(value as? Int == 100)
    }
}
