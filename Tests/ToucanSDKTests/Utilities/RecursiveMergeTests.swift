//
//  RecursiveMergeTests.swift
//  Toucan
//
//  Created by Binary Birds on 2025. 04. 15..
//

import Testing
import ToucanSource
import ToucanSDK

@Suite
struct RecursiveMergeTests {

    @Test
    func testBasicMerge() throws {
        let a: [String: AnyCodable] = [
            "foo": "a"

        ]
        let b: [String: AnyCodable] = [
            "foo": "b"
        ]

        let c = a.recursivelyMerged(with: b)

        #expect(c["foo"] == "b")
    }

    @Test
    func testComplexMerge() throws {
        let a: [String: Any] = [
            "foo": "a",
            "bar": ["a": AnyCodable("b")],

        ]
        let b: [String: Any] = [
            "foo": "b",
            "bar": ["c": AnyCodable("d")],
        ]
        let c = a.recursivelyMerged(with: b)
        let expected: [String: Any] = [
            "foo": "b",
            "bar": [
                "c": AnyCodable("d"),
                "a": AnyCodable("b"),
            ],
        ]
        #expect(c["foo"] as? String == expected["foo"] as? String)
    }
}
