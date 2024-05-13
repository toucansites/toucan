//
//  File.swift
//
//
//  Created by Tibor Bodecs on 03/05/2024.
//

import XCTest
@testable import Toucan

final class SiteGeneratorTests: XCTestCase {

    func testGeneration() throws {

        let path =
            "/"
            + #file
            .split(separator: "/")
            .dropLast(2)
            .joined(separator: "/")

        let baseUrl = URL(fileURLWithPath: path)
        let srcUrl = baseUrl.appendingPathComponent("src")
        let templatesUrl = srcUrl.appendingPathComponent("templates")
        let publicFilesUrl = srcUrl.appendingPathComponent("public")
        let contentsUrl = srcUrl.appendingPathComponent("contents")
        let distUrl = baseUrl.appendingPathComponent("dist")

        let loader = ContentLoader(path: contentsUrl.path)

        let site = try loader.load()

        XCTAssertEqual(site.posts.count, 3)
        XCTAssertEqual(site.pages.count, 2)
        XCTAssertEqual(site.authors.count, 2)
        XCTAssertEqual(site.tags.count, 2)

        let generator = SiteGenerator(
            site: site,
            templatesUrl: templatesUrl,
            publicFilesUrl: publicFilesUrl,
            outputUrl: distUrl
        )
        try generator.generate()
    }

}
