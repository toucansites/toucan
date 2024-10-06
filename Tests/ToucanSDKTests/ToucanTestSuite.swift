//
//  File.swift
//
//
//  Created by Tibor Bodecs on 03/05/2024.
//

import XCTest
@testable import ToucanSDK

final class ToucanTestSuite: XCTestCase {

    var sitesPath: String {
        "/"
            + #file
            .split(separator: "/")
            .dropLast(3)
            .joined(separator: "/")
            + "/sites/"
    }

    //    func generate(
    //        _ site: String
    //    ) async throws {
    //        let baseUrl = URL(fileURLWithPath: sitesPath)
    //        let siteUrl = baseUrl.appendingPathComponent(site)
    //        let srcUrl = siteUrl.appendingPathComponent("src")
    //        let destUrl = siteUrl.appendingPathComponent("dist")
    //
    //        let toucan = Toucan(
    //            input: srcUrl.path,
    //            output: destUrl.path,
    //            baseUrl: nil
    //        )
    //        try toucan.generate()
    //    }
    //
    //    func testGenerate() async throws {
    //        for argument in [
    //            //                "minimal",
    //            "demo"
    //            //            "theswiftdev.com",
    //            //            "binarybirds.com",
    //            //            "swiftonserver.com",
    //        ] {
    //            try await generate(argument)
    //        }
    //    }
}
