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

/// Responsible for copying content-specific asset files from the source directory
/// to the final output location during site generation.
public struct ContentAssetsWriter {

    // MARK: - Properties

    /// Abstraction over file system operations.
    let fileManager: FileManagerKit

    /// Relative path to the assets directory within a content folder.
    let assetsPath: String

    /// The root output directory where content assets should be copied.
    let assetsFolder: URL

    /// The root source directory containing the original content files.
    let scrDirectory: URL

    // MARK: - Initialization

    /// Creates a new `ContentAssetsWriter` instance.
    ///
    /// - Parameters:
    ///   - fileManager: File system abstraction.
    ///   - assetsPath: The relative path to the content's asset folder.
    ///   - assetsFolder: The target output location for assets.
    ///   - scrDirectory: The root source content directory.
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

    // MARK: - Asset Copying

    /// Copies asset files referenced by a given `Content` item to its corresponding output folder.
    ///
    /// This function creates any missing destination directories and mirrors the structure of assets
    /// from the source folder into the resolved slug-based asset directory.
    ///
    /// - Parameter content: The content item whose assets should be copied.
    /// - Throws: Errors thrown by `FileManagerKit` during directory creation or file copying.
    public func copyContentAssets(content: Content) throws {
        if !content.rawValue.assets.isEmpty {

            // Create slug-based output folder for content assets
            let contentFolder = assetsFolder.appending(
                path: content.slug.resolveForPath()
            )
            try fileManager.createDirectory(at: contentFolder)

            // Resolve original asset path in source directory
            let originContentDir = URL(string: content.rawValue.origin.path)?
                .deletingLastPathComponent().path
            let originFullPath =
                scrDirectory
                .appending(path: originContentDir ?? "")
                .appending(path: assetsPath)

            // Copy each asset to the destination
            for asset in content.rawValue.assets {
                let fromFile = originFullPath.appending(path: asset)
                let toFile = contentFolder.appending(path: asset)

                // Ensure destination folders exist
                try fileManager.createDirectory(
                    at: toFile.deletingLastPathComponent()
                )
                // Copy file
                try fileManager.copy(from: fromFile, to: toFile)
            }
        }
    }
}
