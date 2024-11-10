//
//  File.swift
//  toucan
//
//  Created by Tibor Bodecs on 2024. 11. 10..
//

import XCTest
@testable import ToucanSDK

final class DateFormatterTests: XCTestCase {

    func testISO8601() throws {

        let dateString = "2023-11-20T02:11:29.158Z"
        let formatter = DateFormatters.iso8601
        guard let date = formatter.date(from: dateString) else {
            return XCTFail("Could not decode date.")
        }
        
        let expectation = 1700446289.158
        XCTAssertEqual(date.timeIntervalSince1970, expectation)
        
        let formattedString = formatter.string(from: date)
        XCTAssertEqual(formattedString, dateString)
    }
}
