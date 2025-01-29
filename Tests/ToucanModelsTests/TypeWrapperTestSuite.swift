//
//  File.swift
//  ToucanV2
//
//  Created by Tibor Bodecs on 2025. 01. 21..
//

import Testing
@testable import ToucanModels

@Suite
struct TypeWrapperTestSuite {

    @Test
    func testEquality() {
        #expect(TypeWrapper.bool(true) == TypeWrapper.bool(true))
        #expect(TypeWrapper.bool(true) != TypeWrapper.bool(false))

        #expect(TypeWrapper.int(5) == TypeWrapper.int(5))
        #expect(TypeWrapper.int(5) != TypeWrapper.int(10))

        #expect(TypeWrapper.double(5.5) == TypeWrapper.double(5.5))
        #expect(TypeWrapper.double(5.5) != TypeWrapper.double(10.0))

        #expect(TypeWrapper.string("test") == TypeWrapper.string("test"))
        #expect(TypeWrapper.string("test") != TypeWrapper.string("other"))

        #expect(TypeWrapper.date(0) == TypeWrapper.date(0))
        #expect(TypeWrapper.date(0) != TypeWrapper.date(100))
    }

    @Test
    func testLessThan() {
        #expect(TypeWrapper.bool(false) < TypeWrapper.bool(true))
        #expect(!(TypeWrapper.bool(true) < TypeWrapper.bool(false)))

        #expect(TypeWrapper.int(5) < TypeWrapper.int(10))
        #expect(!(TypeWrapper.int(10) < TypeWrapper.int(5)))

        #expect(TypeWrapper.double(5.5) < TypeWrapper.double(10.0))
        #expect(!(TypeWrapper.double(10.0) < TypeWrapper.double(5.5)))

        #expect(TypeWrapper.string("apple") < TypeWrapper.string("banana"))
        #expect(!(TypeWrapper.string("banana") < TypeWrapper.string("apple")))

        #expect(TypeWrapper.date(0) < TypeWrapper.date(100))
        #expect(!(TypeWrapper.date(100) < TypeWrapper.date(0)))
    }

    @Test
    func testDefaultOrderForDifferentCases() {
        #expect(TypeWrapper.bool(false) < TypeWrapper.int(0))
        #expect(TypeWrapper.int(0) < TypeWrapper.double(0.0))
        #expect(TypeWrapper.double(0.0) < TypeWrapper.string(""))
        #expect(TypeWrapper.string("") < TypeWrapper.date(0))

        #expect(!(TypeWrapper.date(0) < TypeWrapper.string("")))
        #expect(!(TypeWrapper.string("") < TypeWrapper.double(0.0)))
        #expect(!(TypeWrapper.double(0.0) < TypeWrapper.int(0)))
        #expect(!(TypeWrapper.int(0) < TypeWrapper.bool(false)))
    }

    @Test
    func testSorting() {
        let unsorted: [TypeWrapper] = [
            .string("banana"),
            .int(10),
            .bool(true),
            .double(5.5),
            .date(100),
            .bool(false),
            .int(5),
        ]

        let sorted = unsorted.sorted()
        let expected: [TypeWrapper] = [
            .bool(false),
            .bool(true),
            .int(5),
            .int(10),
            .double(5.5),
            .string("banana"),
            .date(100),
        ]

        #expect(sorted == expected)
    }
}
