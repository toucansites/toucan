//
//  AssetsLocatorTestSuite.swift
//  Toucan
//
//  Created by Viasz-Kádi Ferenc on 2025. 03. 04..
//

import Foundation
import Testing
import FileManagerKitTesting

@Suite
struct AssetsLocatorTestSuite {

    @Test()
    func testAssetsLocator() async throws {
        try FileManagerPlayground {
            Directory("src") {
                Directory("assets") {
                    "image.png"
                    "cover.png"
                }
            }
        }
        .test {
            let url = $1.appending(path: "src/")
            let results = $0.find(
                recursively: true,
                at: url
            )
            #expect(results.count == 2)
        }
    }

    @Test()
    func testAssetsLocatorEmpty() async throws {
        try FileManagerPlayground()
            .test {
                let locations = $0.find(
                    recursively: true,
                    at: $1
                )
                #expect(locations.isEmpty)
            }
    }
}
