//
//  File.swift
//
//
//  Created by Tibor Bodecs on 13/06/2024.
//

import XCTest
@testable import ToucanSDK

final class StringExtensionTestSuite: XCTestCase {

    func testValidDatePrefix() {
        let validString = "2023-06-13-example"
        XCTAssert(validString.hasDatePrefix())
    }

    func testInvalidDatePrefixWrongFormat() {
        let invalidString = "13-06-2023-example"
        XCTAssert(invalidString.hasDatePrefix() == false)
    }

    func testInvalidDatePrefixNonNumeric() {
        let invalidString = "2023-06-aa-example"
        XCTAssert(invalidString.hasDatePrefix() == false)
    }

    func testInvalidDatePrefixShortString() {
        let shortString = "2023-06-1"
        XCTAssert(shortString.hasDatePrefix() == false)
    }

    func testEmptyString() {
        let emptyString = ""
        XCTAssert(emptyString.hasDatePrefix() == false)
    }

    func testNoHyphenSuffix() {
        let noHyphenString = "2023-06-13example"
        XCTAssert(noHyphenString.hasDatePrefix() == false)
    }

    func testValidDatePrefixWithDifferentContent() {
        let validString = "2023-06-13-12345"
        XCTAssert(validString.hasDatePrefix())
    }

    func testValidDatePrefixAtStartOfString() {
        let validString = "2023-06-13-"
        XCTAssert(validString.hasDatePrefix())
    }
}
