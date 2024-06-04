//
//  File.swift
//
//
//  Created by Tibor Bodecs on 03/05/2024.
//

import XCTest
@testable import Toucan

final class ContentLoaderTests: XCTestCase {

    func testLoad() throws {

        let path =
            "/"
            + #file
            .split(separator: "/")
            .dropLast(2)
            .joined(separator: "/")
            + "/sites/demo/"

        let baseUrl = URL(fileURLWithPath: path)
        let srcUrl = baseUrl.appendingPathComponent("src")
        let contentsUrl = srcUrl.appendingPathComponent("contents")
        let loader = ContentLoader(
            contentsUrl: contentsUrl,
            fileManager: .default,
            frontMatterParser: .init()
        )
        _ = try loader.load()

    }

    
    func testUserDefined() throws {
        
        let path =
            "/"
            + #file
            .split(separator: "/")
            .dropLast(2)
            .joined(separator: "/")
            + "/sites/demo/"

        let baseUrl = URL(fileURLWithPath: path)
        let srcUrl = baseUrl.appendingPathComponent("src")
        let contentsUrl = srcUrl.appendingPathComponent("contents")
        let loader = ContentLoader(
            contentsUrl: contentsUrl,
            fileManager: .default,
            frontMatterParser: .init()
        )
        let content = try loader.load()
        
        _ = content.blog.author.contents.first?.userDefined
        
    }
}
