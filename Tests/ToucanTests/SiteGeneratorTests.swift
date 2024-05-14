//
//  File.swift
//
//
//  Created by Tibor Bodecs on 03/05/2024.
//

import XCTest
@testable import Toucan

final class SiteGeneratorTests: XCTestCase {

    func testBuild() throws {

        let path =
            "/"
            + #file
            .split(separator: "/")
            .dropLast(2)
            .joined(separator: "/")

        let baseUrl = URL(fileURLWithPath: path)
        let inputUrl = baseUrl.appendingPathComponent("src")
        let outputUrl = baseUrl.appendingPathComponent("dist")

        let generator = Toucan(
            inputUrl: inputUrl,
            outputUrl: outputUrl
        )
        try generator.build()
    }

}
