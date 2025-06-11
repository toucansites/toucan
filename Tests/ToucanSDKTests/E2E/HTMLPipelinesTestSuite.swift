//
//  HTMLPipelinesTestSuite.swift
//  Toucan
//
//  Created by Tibor Bödecs on 2025. 06. 11..
//

import Foundation
import Testing
import Logging
import ToucanCore
import ToucanSource
import FileManagerKitBuilder
@testable import ToucanSDK

@Suite
struct HTMLPipelinesTestSuite {

    @Test
    func test404HTMLPage() throws {
        let now = Date()

        try FileManagerPlayground {
            Mocks.E2E.src(
                now: now
            )
        }
        .test {
            let input = $1.appendingPathIfPresent("src")
            try Toucan(input: input.path()).generate()

            let output = $1.appendingPathIfPresent("docs")
            let notFoundUrl = output.appendingPathIfPresent("404.html")
            let notFound = try String(contentsOf: notFoundUrl)

            #expect(notFound.contains("Not found page contents"))

        }
    }
}
