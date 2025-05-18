//
//  CopyManagerTestSuite.swift
//  Toucan
//
//  Created by Viasz-Kádi Ferenc on 2025. 03. 04..
//

import Foundation
import Testing
import FileManagerKitTesting

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
        .test { _, _ in
            //            let sourceConfig = SourceConfig(
            //                sourceUrl: $1.appending(path: "src/"),
            //                config: .defaults
            //            )
            //            let workDirUrl = $1.appending(path: "workDir/")
            //            let copyManager = CopyManager(
            //                fileManager: $0,
            //                sources: [
            //                    sourceConfig.currentThemeAssetsUrl,
            //                    sourceConfig.currentThemeOverrideAssetsUrl,
            //                    sourceConfig.siteAssetsUrl,
            //                ],
            //                destination: workDirUrl
            //            )
            //            try copyManager.copy()
            //
            //            let expectation = ["cover.png", "image.png"]
            //
            //            var locations =
            //                $0
            //                .find(at: workDirUrl.appending(path: "icons/"))
            //                .sorted()
            //            #expect(locations == expectation)
            //
            //            locations =
            //                $0
            //                .find(at: workDirUrl.appending(path: "images/"))
            //                .sorted()
            //            #expect(locations == expectation)
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
        .test { _, _ in
            //            let sourceConfig = SourceConfig(
            //                sourceUrl: $1.appending(path: "src/"),
            //                config: .defaults
            //            )
            //            let workDirUrl = $1.appending(path: "workDir/")
            //            let copyManager = CopyManager(
            //                fileManager: $0,
            //                sources: [
            //                    sourceConfig.currentThemeAssetsUrl,
            //                    sourceConfig.currentThemeOverrideAssetsUrl,
            //                    sourceConfig.siteAssetsUrl,
            //                ],
            //                destination: workDirUrl
            //            )
            //            try copyManager.copy()
            //
            //            let locations = $0.find(at: workDirUrl).sorted()
            //            #expect(locations.isEmpty)
        }
    }
}
