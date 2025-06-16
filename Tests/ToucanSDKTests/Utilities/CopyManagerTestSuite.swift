//
//  CopyManagerTestSuite.swift
//  Toucan
//
//  Created by Viasz-Kádi Ferenc on 2025. 03. 04..
//

import Foundation
import Testing
import FileManagerKitBuilder
import ToucanSDK

@Suite
struct CopyManagerTestSuite {

    @Test()
    func copyItemsRecursively() async throws {
        try FileManagerPlayground {
            Directory(name: "src") {
                Directory(name: "assets") {
                    Directory(name: "icons") {
                        "foo.svg"
                        "bar.ico"
                    }
                    Directory(name: "images") {
                        "image.png"
                        "cover.jpg"
                    }
                }
            }
            Directory(name: "workDir") {}
        }
        .test {
            let src = $1.appendingPathIfPresent("src/assets")
            let workDirUrl = $1.appendingPathIfPresent("workDir")

            let copyManager = CopyManager(
                fileManager: $0,
                sources: [
                    src
                ],
                destination: workDirUrl
            )
            try copyManager.copy()

            #expect(
                $0.listDirectory(
                    at: workDirUrl.appendingPathIfPresent(
                        "icons"
                    )
                )
                .sorted()
                    == [
                        "foo.svg",
                        "bar.ico",
                    ]
                    .sorted()
            )

            #expect(
                $0.listDirectory(
                    at: workDirUrl.appendingPathIfPresent(
                        "images"
                    )
                )
                .sorted()
                    == [
                        "image.png",
                        "cover.jpg",
                    ]
                    .sorted()
            )

        }
    }

    @Test()
    func copyEmptyDirectory() async throws {
        try FileManagerPlayground {
            Directory(name: "src") {
                Directory(name: "assets") {
                }
            }
            Directory(name: "workDir") {}
        }
        .test {
            let src = $1.appendingPathIfPresent("src/assets")
            let workDirUrl = $1.appendingPathIfPresent("workDir")

            let copyManager = CopyManager(
                fileManager: $0,
                sources: [
                    src
                ],
                destination: workDirUrl
            )
            try copyManager.copy()
            #expect($0.listDirectory(at: workDirUrl).isEmpty)
        }
    }
}
