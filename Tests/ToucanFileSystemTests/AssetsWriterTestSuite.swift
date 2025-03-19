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
struct AssetsWriterTestSuite {

    @Test()
    func testAssetsWriter() async throws {
        try FileManagerPlayground {
            Directory("src") {
                Directory("contents") {
                    Directory("assets") {
                        Directory("icons") {
                            "image.png"
                            "cover.png"
                        }
                        Directory("images") {
                            "image.png"
                            "cover.png"
                        }
                    }
                }
            }
            Directory("workDir") {}
        }
        .test {
            let sourceConfig = SourceConfig(
                sourceUrl: $1.appending(path: "src/"),
                config: .defaults
            )
            let workDirUrl = $1.appending(path: "workDir/")
            let assetsWriter = AssetsWriter(
                fileManager: $0,
                sourceConfig: sourceConfig,
                workDirUrl: workDirUrl
            )
            try assetsWriter.copyDefaultAssets()
            
            let expectation = ["cover.png", "image.png"]
            let locator = FileLocator(fileManager: $0)
            
            var locations = locator.locate(at: workDirUrl.appending(path: "icons/")).sorted()
            #expect(locations == expectation)
            
            locations = locator.locate(at: workDirUrl.appending(path: "images/")).sorted()
            #expect(locations == expectation)
        }
    }

    @Test()
    func testAssetsWriterEmpty() async throws {
        try FileManagerPlayground {
            Directory("src") {
                Directory("contents") {
                    Directory("assets") {
                    }
                }
            }
            Directory("workDir") {}
        }
        .test {
            let sourceConfig = SourceConfig(
                sourceUrl: $1.appending(path: "src/"),
                config: .defaults
            )
            let workDirUrl = $1.appending(path: "workDir/")
            let assetsWriter = AssetsWriter(
                fileManager: $0,
                sourceConfig: sourceConfig,
                workDirUrl: workDirUrl
            )
            try assetsWriter.copyDefaultAssets()
            
            let locator = FileLocator(fileManager: $0)
            var locations = locator.locate(at: workDirUrl).sorted()
            #expect(locations.isEmpty)
        }
    }
}
