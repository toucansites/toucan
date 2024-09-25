//
//  File.swift
//
//
//  Created by Tibor Bodecs on 03/05/2024.
//

import XCTest
@testable import ToucanSDK

final class SourceTestSuite: XCTestCase {

    var sitesPath: String {
        "/"
            + #file
            .split(separator: "/")
            .dropLast(3)
            .joined(separator: "/")
            + "/sites/"
    }

    func loadConfig(
        _ site: String
    ) async throws {
        let baseUrl = URL(fileURLWithPath: sitesPath)
        let siteUrl = baseUrl.appendingPathComponent(site)
        let srcUrl = siteUrl.appendingPathComponent("src")
        let configLoader = SourceConfigLoader(
            sourceUrl: srcUrl,
            fileManager: .default,
            frontMatterParser: .init()
        )
        _ = try configLoader.load()
    }

    func testLoadConfig() async throws {
        for argument in [
            "demo"
            //            "theswiftdev.com",
            //            "binarybirds.com",
            //            "swiftonserver.com",
        ] {
            try await loadConfig(argument)
        }

    }

    func loadContents(
        _ site: String
    ) async throws {
        let baseUrl = URL(fileURLWithPath: sitesPath)
        let siteUrl = baseUrl.appendingPathComponent(site)
        let srcUrl = siteUrl.appendingPathComponent("src")
        let configLoader = SourceConfigLoader(
            sourceUrl: srcUrl,
            fileManager: .default,
            frontMatterParser: .init()
        )
        let config = try configLoader.load()

        let contentsLoader = SourceMaterialLoader(
            config: config,
            fileManager: .default,
            frontMatterParser: .init()
        )

        let contents = try contentsLoader.load()
        try contents.validateSlugs()
    }

    func testLoadContents() async throws {
        for argument in [
            "demo"
            //            "theswiftdev.com",
            //            "binarybirds.com",
            //            "swiftonserver.com",
        ] {
            try await loadContents(argument)
        }

    }

    //    func testUserDefined() async throws {
    //
    //        let path =
    //            "/"
    //            + #file
    //            .split(separator: "/")
    //            .dropLast(3)
    //            .joined(separator: "/")
    //            + "/sites/demo/"
    //
    //        let baseUrl = URL(fileURLWithPath: path)
    //        let srcUrl = baseUrl.appendingPathComponent("src")
    //        let contentsUrl = srcUrl.appendingPathComponent("contents")
    //        let loader = ContentLoader(
    //            contentsUrl: contentsUrl,
    //            fileManager: .default,
    //            frontMatterParser: .init()
    //        )
    //        let content = try await loader.load()
    //
    //        _ = content.blog.author.contents.first?.userDefined
    //
    //    }
}
