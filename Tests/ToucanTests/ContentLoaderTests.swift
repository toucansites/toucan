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

        let baseUrl = URL(filePath: path)
        let srcUrl = baseUrl.appending(path: "src")
        let contentsUrl = srcUrl.appending(path: "contents")

        let loader = ContentLoader(path: contentsUrl.path)

        let site = try loader.load()

        print(site)

    }

}
