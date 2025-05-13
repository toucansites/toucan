//
//  AssetsWriter.swift
//  Toucan
//
//  Created by gerp83 on 2025. 04. 17..
//

import Foundation
import FileManagerKit
import ToucanModels

/// Responsible for copying static assets from various source locations into the working directory.
public struct AssetsWriter {

    // MARK: - Properties

    /// File manager abstraction for performing file operations.
    let fileManager: FileManagerKit

    /// Source configuration, containing paths to asset directories.
    let sourceConfig: SourceConfig

    /// The target directory where all assets should be written.
    let workDirUrl: URL

    // MARK: - Initialization

    /// Initializes a new asset writer for copying static files.
    ///
    /// - Parameters:
    ///   - fileManager: The file system manager.
    ///   - sourceConfig: Provides asset paths based on the source bundle.
    ///   - workDirUrl: Target directory for copying all assets.
    public init(
        fileManager: FileManagerKit,
        sourceConfig: SourceConfig,
        workDirUrl: URL
    ) {
        self.fileManager = fileManager
        self.sourceConfig = sourceConfig
        self.workDirUrl = workDirUrl
    }

    // MARK: - Copy Operation

    /// Copies all default, overridden, and site-level assets into the working directory.
    ///
    /// This includes:
    /// - Theme assets
    /// - Theme override assets (if present)
    /// - Global site assets (e.g., images, documents)
    ///
    /// - Throws: Errors from the file system if copying fails.
    public func copyDefaultAssets() throws {
        // Copy default theme assets
        try fileManager.copyRecursively(
            from: sourceConfig.currentThemeAssetsUrl,
            to: workDirUrl
        )

        // Copy theme override assets (if any)
        try fileManager.copyRecursively(
            from: sourceConfig.currentThemeOverrideAssetsUrl,
            to: workDirUrl
        )

        // Copy global/static site-level assets
        try fileManager.copyRecursively(
            from: sourceConfig.siteAssetsUrl,
            to: workDirUrl
        )
    }
}
