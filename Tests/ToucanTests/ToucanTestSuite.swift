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
            "demo",
            "theswiftdev.com",
        ]
    )
    func generate(
        _ site: String
    ) async throws {
        let baseUrl = URL(fileURLWithPath: sitesPath)
        let siteUrl = baseUrl.appendingPathComponent(site)
        let srcUrl = siteUrl.appendingPathComponent("src")
        let templatesUrl = srcUrl.appendingPathComponent("templates")
        let contentsUrl = srcUrl.appendingPathComponent("contents")
        let configFileUrl = contentsUrl.appendingPathComponent("config.yaml")
        let destUrl = siteUrl.appendingPathComponent("dist")
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

        let site = Site(
            source: .init(
                config: config,
                contents: contents,
                assets: .init(
                    storage: [:]
                )
            ),
            destinationUrl: destUrl
        )

        let renderer = SiteGenerator(
            site: site,
            templatesUrl: templatesUrl
        )

        try renderer.render()
    }
}
