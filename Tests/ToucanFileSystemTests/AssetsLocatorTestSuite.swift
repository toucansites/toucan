//
//  File.swift
//  toucan
//
//  Created by Viasz-Kádi Ferenc on 2025. 03. 04..
//

import Foundation
import Testing
import FileManagerKitTesting
@testable import ToucanFileSystem
import ToucanModels

@Suite
struct AssetsLocatorTestSuite {

    @Test()
    func testAssetsLocator() async throws {
        try FileManagerPlayground {
            Directory("src") {
                Directory("contents") {
                    Directory("assets") {
                        "image.png"
                        "cover.png"
                    }
                }
            }
        }
        .test {
            let url = $1.appending(path: "src/contents/")
            let locator = AssetLocator(fileManager: $0)
            let results = locator.locate(at: url)
            
            #expect(results.count == 2)
        }
    }

    @Test()
    func testAssetsLocatorEmpty() async throws {
        try FileManagerPlayground()
            .test {
                let locator = AssetLocator(fileManager: $0)
                let locations = locator.locate(at: $1)

                #expect(locations.isEmpty)
            }
    }
}
