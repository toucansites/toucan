//
//  File.swift
//
//
//  Created by Tibor Bodecs on 03/05/2024.
//

import XCTest
@testable import ToucanSDK

final class FrontMatterParserTests: XCTestCase {

    func testBasics() throws {

        let input = #"""
            ---
            slug: lorem-ipsum
            title: Lorem ipsum
            tags: foo, bar, baz
            ---

            Lorem ipsum dolor sit amet.
            """#

        let parser = FrontMatterParser()
        let metadata = try parser.parse(markdown: input) as? [String: String]

        let expectation: [String: String] = [
            "slug": "lorem-ipsum",
            "title": "Lorem ipsum",
            "tags": "foo, bar, baz",
        ]

        XCTAssert(metadata == expectation)
    }

}
