import Foundation
import Testing
import ToucanSource
@testable import ToucanModels

@Suite
struct QueryDecodingTestSuite {

    // MARK: - order

    @Test
    func orderDefaultSortDirection() throws {
        let data = """
            key: name
            """
            .data(using: .utf8)!

        let decoder = ToucanYAMLDecoder()

        let result = try decoder.decode(
            Order.self,
            from: data
        )

        #expect(result.key == "name")
        #expect(result.direction == .asc)
    }

    @Test
    func orderCustomSortDirection() throws {
        let data = """
            key: name
            direction: desc
            """
            .data(using: .utf8)!

        let decoder = ToucanYAMLDecoder()

        let result = try decoder.decode(
            Order.self,
            from: data
        )

        #expect(result.key == "name")
        #expect(result.direction == .desc)
    }

    // MARK: - condition

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
        #expect(value.value(as: String.self) == "hello")
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
        #expect(value.value(as: [String].self) == ["foo", "bar", "baz"])
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
        #expect(value.value(as: String.self) == "hello")
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

    // MARK: - query

    @Test
    func minimalQuery() throws {

        let data = """
            contentType: post
            """
            .data(using: .utf8)!

        let decoder = ToucanYAMLDecoder()

        let result = try decoder.decode(
            Query.self,
            from: data
        )

        #expect(result.contentType == "post")
        #expect(result.scope == nil)
        #expect(result.limit == nil)
        #expect(result.offset == nil)
        #expect(result.filter == nil)
        #expect(result.orderBy.isEmpty)
    }

    @Test
    func simpleQuery() throws {

        let data = """
            contentType: post
            scope: list
            limit: 1
            offset: 0
            filter:
                key: name
                operator: equals
                value: hello
            orderBy:
                - key: name
                - key: other
                  direction: desc
            """
            .data(using: .utf8)!

        let decoder = ToucanYAMLDecoder()

        let result = try decoder.decode(
            Query.self,
            from: data
        )

        #expect(result.contentType == "post")
        #expect(result.scope == "list")
        #expect(result.limit == 1)
        #expect(result.offset == 0)

        guard case let .field(key, op, value) = result.filter else {
            Issue.record("Result is not a field case.")
            return
        }

        #expect(key == "name")
        #expect(op == .equals)
        #expect(value.value(as: String.self) == "hello")

        try #require(result.orderBy.count == 2)
        #expect(result.orderBy[0].key == "name")
        #expect(result.orderBy[0].direction == .asc)
        #expect(result.orderBy[1].key == "other")
        #expect(result.orderBy[1].direction == .desc)
    }
}
