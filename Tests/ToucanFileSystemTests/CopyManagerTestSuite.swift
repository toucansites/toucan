//
//  CopyManagerTestSuite.swift
//  Toucan
//
//  Created by Viasz-Kádi Ferenc on 2025. 03. 04..
//

import Foundation
import Testing
import FileManagerKitTesting
@testable import ToucanFileSystem
import ToucanModels

@Suite
struct CopyManagerTestSuite {

    @Test()
    func copyItemsRecursively() async throws {
        try FileManagerPlayground {
            Directory("src") {
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
            Directory("workDir") {}
        }
        .test {
            let sourceConfig = SourceConfig(
                sourceUrl: $1.appending(path: "src/"),
                config: .defaults
            )
            let workDirUrl = $1.appending(path: "workDir/")
            let copyManager = CopyManager(
                fileManager: $0,
                sources: [
                    sourceConfig.currentThemeAssetsUrl,
                    sourceConfig.currentThemeOverrideAssetsUrl,
                    sourceConfig.siteAssetsUrl,
                ],
                destination: workDirUrl
            )
            try copyManager.copy()

            let expectation = ["cover.png", "image.png"]
            let locator = FileLocator(fileManager: $0)

            var locations =
                locator.locate(at: workDirUrl.appending(path: "icons/"))
                .sorted()
            #expect(locations == expectation)

            locations =
                locator.locate(at: workDirUrl.appending(path: "images/"))
                .sorted()
            #expect(locations == expectation)
        }
    }

    @Test()
    func copyEmptyDirectory() async throws {
        try FileManagerPlayground {
            Directory("src") {
                Directory("assets") {
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
            let copyManager = CopyManager(
                fileManager: $0,
                sources: [
                    sourceConfig.currentThemeAssetsUrl,
                    sourceConfig.currentThemeOverrideAssetsUrl,
                    sourceConfig.siteAssetsUrl,
                ],
                destination: workDirUrl
            )
            try copyManager.copy()

            let locator = FileLocator(fileManager: $0)
            let locations = locator.locate(at: workDirUrl).sorted()
            #expect(locations.isEmpty)
        }
    }
}
