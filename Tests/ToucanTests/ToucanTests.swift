//
//  File.swift
//
//
//  Created by Tibor Bodecs on 03/05/2024.
//

import XCTest
@testable import Toucan

final class ToucanTests: XCTestCase {

    func testGenerateSites() async throws {

        let sitesPath =
            "/"
            + #file
            .split(separator: "/")
            .dropLast(2)
            .joined(separator: "/")
            + "/sites"

        let sitesUrl = URL(fileURLWithPath: sitesPath)
        let sites = FileManager.default.listDirectory(at: sitesUrl)

        
        for site in sites {
            
            if !site.contains("theswiftdev") {
                continue
            }
            
            let siteUrl = sitesUrl.appendingPathComponent(site)
            let inputUrl = siteUrl.appendingPathComponent("src")
            let outputUrl = siteUrl.appendingPathComponent("dist")
            
            let generator = Toucan(
                inputUrl: inputUrl,
                outputUrl: outputUrl
            )
            
            try await generator.build()
        }
    }
}
