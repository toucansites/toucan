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
struct SiteSourceTestSuite {

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
            "demo",
            "theswiftdev.com",
        ]
    )
    func loadConfig(
        _ site: String
    ) async throws {
        let baseUrl = URL(fileURLWithPath: sitesPath)
        let siteUrl = baseUrl.appendingPathComponent(site)
        let srcUrl = siteUrl.appendingPathComponent("src")
        let contentsUrl = srcUrl.appendingPathComponent("contents")
        let configFileUrl = contentsUrl.appendingPathComponent("config.yaml")
        let configLoader = Source.ConfigLoader(
            configFileUrl: configFileUrl,
            fileManager: .default,
            frontMatterParser: .init()
        )
        _ = try configLoader.load()
    }
    
    @Test(
        arguments: [
            "demo",
            "theswiftdev.com",
        ]
    )
    func loadContents(
        _ site: String
    ) async throws {
        let baseUrl = URL(fileURLWithPath: sitesPath)
        let siteUrl = baseUrl.appendingPathComponent(site)
        let srcUrl = siteUrl.appendingPathComponent("src")
        let contentsUrl = srcUrl.appendingPathComponent("contents")
        let configFileUrl = contentsUrl.appendingPathComponent("config.yaml")
        let configLoader = Source.ConfigLoader(
            configFileUrl: configFileUrl,
            fileManager: .default,
            frontMatterParser: .init()
        )
        let config = try configLoader.load()
        
        let contentsLoader = Source.ContentsLoader(
            contentsUrl: contentsUrl,
            config: config,
            fileManager: .default,
            frontMatterParser: .init()
        )
        
        let contents = try contentsLoader.load()
        for content in contents.all() {
            print(content.slug)
        }
        try contents.validateSlugs()
    }
    
    //
    //    @Test
    //    func userDefined() async throws {
    //
    //        let path =
    //            "/"
    //            + #file
    //            .split(separator: "/")
    //            .dropLast(2)
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
