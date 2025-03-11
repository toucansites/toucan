//
//  AssetsWriter.swift
//
//  Created by gerp83 on 2025. 03. 05.
//

import Foundation
import FileManagerKit
import ToucanModels

public struct AssetsWriter {

    let fileManager: FileManagerKit
    let sourceConfig: SourceConfig
    let contentAssets: [String]
    let workDirUrl: URL

    public init(
        fileManager: FileManagerKit,
        sourceConfig: SourceConfig,
        contentAssets: [String],
        workDirUrl: URL
    ) {
        self.fileManager = fileManager
        self.sourceConfig = sourceConfig
        self.contentAssets = contentAssets
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
    
    public func copyContentAssests(destinationFolder: URL, contentPath: String) throws {
        let filtered = contentAssets.filter {$0.contains(contentPath + "/assets")}
        
        // if the contentPath has assets in the src directory, then it's always has one folder 'assets'
        if let directory = filtered.first {
            
            let assetsFolderFrom = sourceConfig.contentsUrl.appendingPathComponent(directory)
            let assetsFolderTo = destinationFolder.appendingPathComponent("assets")
            
            // create assests folder
            try fileManager.createDirectory(at: assetsFolderTo)
            
            // copy files
            try fileManager.copyRecursively(
                from: assetsFolderFrom,
                to: assetsFolderTo
            )
        }
        
    }

}
