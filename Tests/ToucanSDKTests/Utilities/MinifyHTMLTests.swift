//
//  File.swift
//
//
//  Created by Tibor Bodecs on 13/05/2024.
//

import XCTest
@testable import ToucanSDK

final class MinifyHTMLTests: XCTestCase {

    func testMinify() throws {

        let html =
            "<html>   <body>   <h1>Hello, world!</h1>   </body>   </html>"
        let minifiedHTML = html.minifyHTML()
        //        print(minifiedHTML)

        XCTAssert(!minifiedHTML.isEmpty)
    }

}
