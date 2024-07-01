//
//  File.swift
//
//
//  Created by Tibor Bodecs on 03/05/2024.
//

import Foundation

import Testing
@testable import Toucan

@Suite
struct ToucanTestSuite {

    var sitesPath: String {
        "/"
            + #file
            .split(separator: "/")
            .dropLast(2)
            .joined(separator: "/")
            + "/sites/"
    }

    @Test(
        arguments: [
            "minimal",
            "demo",
//            "theswiftdev.com",
        ]
    )
    func generate(
        _ site: String
    ) async throws {
        let baseUrl = URL(fileURLWithPath: sitesPath)
        let siteUrl = baseUrl.appendingPathComponent(site)
        let srcUrl = siteUrl.appendingPathComponent("src")
        let destUrl = siteUrl.appendingPathComponent("dist")

        let toucan = Toucan(
            inputUrl: srcUrl,
            outputUrl: destUrl
        )
        try await toucan.run()        
    }
}
