//
//  ContentAssetsWriter.swift
//  Toucan
//
//  Created by gerp83 on 2025. 03. 05.
//

import Foundation
import FileManagerKit
import ToucanContent
import ToucanModels

public struct ContentAssetsWriter {

    let fileManager: FileManagerKit
    let assetsPath: String
    let assetsFolder: URL
    let scrDirectory: URL

    public init(
        fileManager: FileManagerKit,
        assetsPath: String,
        assetsFolder: URL,
        scrDirectory: URL
    ) {
        self.fileManager = fileManager
        self.assetsPath = assetsPath
        self.assetsFolder = assetsFolder
        self.scrDirectory = scrDirectory
    }

    public func copyContentAssets(content: Content) throws {
        if !content.rawValue.assets.isEmpty {

            let contentFolder = assetsFolder.appending(
                path: content.slug.resolveForPath()
            )
            try fileManager.createDirectory(at: contentFolder)

            let originContentDir = URL(string: content.rawValue.origin.path)?
                .deletingLastPathComponent().path
            let originFullPath =
                scrDirectory.appending(path: originContentDir ?? "")
                .appending(path: assetsPath)

            for asset in content.rawValue.assets {
                let fromFile = originFullPath.appending(path: asset)
                let toFile = contentFolder.appending(path: asset)

                try fileManager.createDirectory(
                    at: toFile.deletingLastPathComponent()
                )
                try fileManager.copy(from: fromFile, to: toFile)
            }
        }
    }

}
