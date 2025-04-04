//
//  AssetsWriter.swift
//  Toucan
//
//  Created by gerp83 on 2025. 03. 05.
//

import Foundation
import FileManagerKit
import ToucanModels

public struct AssetsWriter {

    let fileManager: FileManagerKit
    let sourceConfig: SourceConfig
    let workDirUrl: URL

    public init(
        fileManager: FileManagerKit,
        sourceConfig: SourceConfig,
        workDirUrl: URL
    ) {
        self.fileManager = fileManager
        self.sourceConfig = sourceConfig
        self.workDirUrl = workDirUrl
    }

    public func copyDefaultAssets() throws {

        // theme assets
        try fileManager.copyRecursively(
            from: sourceConfig.currentThemeAssetsUrl,
            to: workDirUrl
        )

        // theme override assets
        try fileManager.copyRecursively(
            from: sourceConfig.currentThemeOverrideAssetsUrl,
            to: workDirUrl
        )

        // copy global site assets
        try fileManager.copyRecursively(
            from: sourceConfig.assetsUrl,
            to: workDirUrl
        )

    }

}
