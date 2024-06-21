//
//  File.swift
//
//
//  Created by Tibor Bodecs on 13/05/2024.
//

import Testing
@testable import Toucan

@Suite
struct MinifyHTMLTests {

    @Test
    func testMinify() throws {

        let html =
            "<html>   <body>   <h1>Hello, world!</h1>   </body>   </html>"
        let minifiedHTML = html.minifyHTML()
        print(minifiedHTML)

    }

}
